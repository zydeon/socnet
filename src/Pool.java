// Based on the example given on http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/Semaphore.html
package dbconnect;

import java.sql.Connection;
import java.util.concurrent.Semaphore;
import java.util.ArrayList;
import java.util.Iterator;
import dbconnect.Database;

public class Pool {
	private static int MAX_AVAILABLE;
	private Semaphore available;
	private ArrayList<Connection> items;

	public Pool( int max_items ){
		MAX_AVAILABLE = max_items;
		available     = new Semaphore(MAX_AVAILABLE, true);
		items         = new ArrayList<Connection>();

		int i;
		Connection c;
		for( i = 0; i < MAX_AVAILABLE; ++i ){
			c = Database.createConnection();
			if( c!=null )
				items.add( c );
		}	
	}

	public synchronized Connection getItem() throws InterruptedException {
		available.acquire();
		return (Connection) items.remove(0);
	}

	public synchronized void putItem(Connection c) {
		items.add(c);
		available.release();
	}

	public void destroy(){
		try{
			for( Iterator<Connection> i=items.iterator(); i.hasNext(); )
				i.next().close();
		}
		catch(java.sql.SQLException e){
			System.out.println(e);
		}
	}

}