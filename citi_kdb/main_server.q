/ q main_server.q -p [port]

/ Schemas
trades:flip`OrderNo`ActivityTime`FillNumber`ResponseType`OrderID`Symbol`Side`Price`Quantity`AccountID`ErrorCode`TimeStamp`Exchange_Order_Id`ChildResponseType`Duration`ExchTs!"JPJSJSSFJSIJ*SS*"$\:()
summ:3!flip`dateTransact`accID`sym`open`high`low`vol`val`lastTransact!"DSSFFFJFP"$\:()

/ Update analytics
upd:{ 
    x insert y;
    updSumm`;
    }

/ Daily summary table analytics grouped by AccountID, Symbol
/ 1. Price (open)
/ 2. Price (high)
/ 3. Price (low)
/ 4. Total trade (vol)ume
/ 5. Change in trade (val)ue
/ 6. Last transacted (lastTransact)
updSumm:{
    / Aggregate trades table
    new:select 
        open:first Price,
        low:min Price,
        high:max Price,
        vol:sum Quantity,
        val:sum ?[Side=`B;1;-1]*Quantity*Price,
        lastTransact:last ActivityTime 
    by
        dateTransact:"d"$ActivityTime,
        accID:AccountID,
        sym:Symbol 
    from `ActivityTime xasc `trades;

    / Take existing opening price
    new:new lj select last open by dateTransact,sym from `summ;

    / Combine newly aggregated table with summary table
    combined:(0!new),select dateTransact,accID,sym,open,low,high,vol,val,lastTransact from `summ;
    combined:select last open,min low,max high,sum vol,sum val,max lastTransact by dateTransact,accID,sym from combined;

    `summ upsert combined;
    `trades set 0#trades;
    }

/ Save down
lastSaved:.z.p
symDir:(`:.;hsym dbRoot) count dbRoot:`$getenv`DB_ROOT

splaySumm:{
    .Q.dd/[(hsym dbRoot;`summ;`)] upsert .Q.en[symDir]`time xcols 0!update time:.z.p from get`summ;
    delete from `summ where dateTransact<>(last;dateTransact) fby ([]accID;sym);
    lastSaved::.z.p
    }

/ Functions to be called through WebSocket
.z.ws: { value x }
.z.wc: { delete from `subs where handle=x }
loadPage:{ sub[`getSumm;enlist`] }
getSumm:{
    res:select from `summ;
    `func`result!(`getSumm;res)
    }

/ Subscription table to keep track of current subscriptions via Websocket
subs:2!flip `handle`func`params!"is*"$\:()
sub:{ `subs upsert(.z.w;x;enlist y) }
pub:{
    row:(0!subs)[x];
    (neg row[`handle]) .j.j (value row[`func])[row[`params]]
    }

/ Timer function
.z.ts:{
    if[00:00:10<.z.p-lastSaved;splaySumm`];
    pub each til count subs;
    }

/ Initialize process
\t 1000