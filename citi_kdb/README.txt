STARTUP INSTRUCTIONS

Logs Generator - This kdb process generates mocked trade logs in the specified format and writes to a log file with the specified naming convention.

1. In a new session, set environment variables
	TRADE_LOG_CID=1
	TRADE_LOG_DIR=<desired directory to set log file>
		e.g. TRADE_LOG_DIR=c:/Users/congr/Desktop/Python/random_projects/citi_kdb

2. Run 
	q client_logger.q
to start up this process.
3. Once started up, the log file for the day (and necessary parent directories) will be created. The process has been configured to log between 10 and 20 entries per second.
	


Client Feed - This kdb process routinely monitors the size of the log file and publishes any appended log entries to the Main Server.

1. In a new session, set environment variables
	TRADE_LOG_CID=1
	TRADE_LOG_DIR=<desired directory to set log file>
		e.g. TRADE_LOG_DIR=c:/Users/congr/Desktop/Python/random_projects/citi_kdb
This should be identical to the ones used in the Logs Generator session.

2. Run
	q client_feed.q :5050
to start up the process. The main server handle can be provided as a command line argument in the format [host]:port[:user:pwd].
3. Once started up, it should have registered the cursor (which is used as an offset) of the existing log file, and it will constantly attempt to connect to the Main Server. If the Main Server is restarted, run
	connectToServer`
in the process to re-establish connection.



Main Server - This kdb process receives log entries from (potentially many) Client Feed. It contains a schema for the trade logs (which should be identical to that in Client Feed processes) for the sole purpose of ensuring column consistency on receipt. In its update analytic, a summary report is calculated from trade entries received and merged with the existing summary report. Every ~10 seconds, the summary report is splayed under the DB_ROOT directory which is subsequently appended, and only 1 entry per AccountID and Symbol is kept in-memory. The concise summary report is viewable through the websockets.html file (which currently only works locally).

1. In a new session, set environment variables DB_ROOT=<desired directory to splay summary report>.

2. Run
	q main_server.q -p 5050
to start up the process. The port is configurable, but relevant changes needs to be made to client_feed.q and websockets.js.

3. Once started up, the `summ table should be populated. Opening websockets.html in your browser should display the real-time `summ table.