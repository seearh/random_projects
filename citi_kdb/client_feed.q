/ q client_feed.q [host]:port[:usr:pwd]

/ Trades log file
cid:1i^"I"$getenv`TRADE_LOG_CID
logDir:`:.^hsym`$getenv`TRADE_LOG_DIR

logInit:{
    logFilename::.Q.dd over (`$"tradeLog_client",string cid;prevDay::.z.d;`log);
    logFile::.Q.dd[logDir;logFilename];
    readTill::@[hcount;logFile;0N];
    }

/ Connection to main server
connectToServer:{
    serverConn::(hsym `$":",h;`::5050) ""~h:.z.x 0;
    serverHandle::@[hopen;serverConn;
        / Reconnection logic
        {0N!"Failed to connect to server: ",-3!x;:0Ni}];
    }

/ Read & publish log
colMapping:colTypes:(
    [column:`OrderNo,(`$"Activity Time"),`FillNumber`ResponseType`OrderID`Symbol`Side`Price`Quantity`AccountID`ErrorCode`TimeStamp`Exchange_Order_Id`ChildResponseType`Duration`ExchTs]
    columnName:``ActivityTime``````````````;
    columnType:"JPJSJSSFJSIJ*SS*"
    )

readLog:{
    if[(readTill~h:@[hcount;logFile;0N]) or null readTill;:()];
    s:read0 (x;readTill;r:h-readTill);
    readTill::h;
    t:((!/)"S:|"0:) each s;
    a:exec (column^columnName)!flip ($;columnType;column) from colMapping;
    t:key[a]#![t;();0b;a]
    }

pubLog:{
    if[0~count l:readLog x;:()];
    0N!"Publishing ",(-3!count l)," records to server";
    neg[serverHandle](`upd;`trades;l);
    neg[serverHandle][];
    }

.z.ts:{
    if[null readTill;logInit`];
    if[null serverHandle;connectToServer`;:()];             / Reconnection logic
    if[not prevDay~"d"$x;pubLog logFile;logInit`];          / Log rollover
    pubLog logFile
    }

/ Initialize process
logInit`
connectToServer`
\t 100