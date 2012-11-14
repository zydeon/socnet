import java.util.ArrayList;

public class Post extends Message{

	//private static final long serialVersionU = 1L;

	protected int parent;
	protected int replyLevel; 
	private ArrayList<Integer> replies;
	public boolean read;

	public Post(String src ){
		super(src);
		this.parent = 0;
		this.replyLevel = 0;
		this.replies = new ArrayList<Integer>();
	}	


	public Post(String src, String text ){
		super(src, text);
		this.parent = 0;
		this.replyLevel = 0;
		this.replies = new ArrayList<Integer>();
	}	

	public Post(String src, int parent, int replyLevel ){
		super(src);
		this.parent = parent;
		this.replyLevel = replyLevel;
		this.replies = new ArrayList<Integer>();
	}

	public int getReplyLevel(){
		return replyLevel;
	}

	public ArrayList<Integer> getReplies(){
		return replies;
	}

	public void addReply(int replyID){
		replies.add(replyID);
	}
	
	public int getParent(){
		return parent;
	}	

	public boolean unread(){
		return !read;
	}

	public String toString(){
		return  replyGap()+ID+": POST on "+ sentDate.toString() +" from '"+source+
				"'\n"+replyGap()+">"+text+"read="+read+"\n";
	}	

	private String replyGap(){
		int i; String gap = "";
		for( i = 0; i < replyLevel; ++i )
			gap += "\t";
		
		return gap;
	}	
}
