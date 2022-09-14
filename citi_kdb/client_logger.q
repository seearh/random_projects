/ q client_logger.q

/ Trades log file
cid:1i^"I"$getenv`TRADE_LOG_CID
logDir:`:.^hsym`$getenv`TRADE_LOG_DIR
logTemplate:"OrderNo:16000000000001|Activity Time:{time}",
	"|FillNumber:600110663|ResponseType:TRADE_CONFIRM|OrderID:1|Symbol:{sym}",
	"|Side:{side}|Price:{price}|Quantity:{qty}|AccountID:{accID}",
	"|ErrorCode:0|TimeStamp:1633924085|Exchange_Order_Id:483425880054544049 6",
	"|ChildResponseType:NULL_RESPONSE_MIDDLE|Duration:GTC|ExchTs:33959 25290703"

logInit:{
	logFilename::.Q.dd over (`$"tradeLog_client",string cid;prevDay::.z.d;`log);
	logHandle::hopen logFile::.Q.dd[logDir;logFilename];
	}

fillLogTemplate:{[template;vars]
	ssr/[template].(({x,y,z}'["{";;"}"] string key@);value)@\:@[vars;where 10<>type each vars;string]
	}

/ Trade generation variables
lBound:10   / inclusive
uBound:21   / exclusive
trades:flip `time`accID`sym`side`price`qty!"psssfj"$\:();

tradesInit:{
	/ Populate with ~10 seconds of trades
	`trades set 0#trades;
	fill10SecTrades .z.p;
	}

fillNTradesBetween:{[n;s;e]
	`trades insert
	([] time:asc s+n?e-s;
	accID:n?`CQ01`CQ02`CQ03;
	sym:n?`BANKNIFTY`AAPL`AMZN`FB`GOOG;
	side:n?`B`S;
	price:(n?100000)%100;
	qty:n?100 );
	`time xasc `trades;
	}

fill10SecTrades:{
	fillNTradesBetween[10*first lBound+1?uBound-lBound;x;x+00:00:10]
	}

/ Timer function
.z.ts:{
	if[not prevDay~"d"$x;logInit`];                             / Log file rollover
	t:select from trades where time<x;                          / Write logs then delete trades before current time
	t:update time:.[string time;((::);10);:;" "] from t;
	neg[logHandle] fillLogTemplate[logTemplate] each t;
	delete from `trades where time<x;
	if[00:00:03>(l:x^last[trades]`time)-x;fill10SecTrades l];	/ Replenish 10s of trades when left with 3s of trades
	}

/ Initialize process
logInit`
tradesInit`
\t 100