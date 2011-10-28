package ltg.ps.clients.commons {
	import com.hurlant.util.asn1.parser.boolean;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	
	import flashx.textLayout.accessibility.TextAccImpl;
	
	import ltg.ps.clients.helioroom.Main_vector;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.XMPPStanza;
	import org.igniterealtime.xiff.events.DisconnectionEvent;
	import org.igniterealtime.xiff.events.IQEvent;
	import org.igniterealtime.xiff.events.LoginEvent;
	import org.igniterealtime.xiff.events.MessageEvent;
	import org.igniterealtime.xiff.events.OutgoingDataEvent;
	import org.igniterealtime.xiff.events.PresenceEvent;
	import org.igniterealtime.xiff.events.XIFFErrorEvent;
	
	public class ClientNetworkController extends EventDispatcher {
		
		// Events
		public static const UPDATE_RECEIVED:String = "updateReceived";
		
		// Connection
		private var xmppConnection:XMPPConnection = null;
		private var podId:String = null;

		
		public function ClientNetworkController(serverhost:String, username:String, password:String, pod:String) {
			xmppConnection = new XMPPConnection();
			xmppConnection.resource = "HelioRoomStudentClient";
			this.podId = pod;
			xmppConnection.server = serverhost;
			xmppConnection.port = 5222;
			var s:Array = username.split("@",2);
			//xmppConnection.username = username;	//openfire
			xmppConnection.username = s[0];			//ejabberd
			xmppConnection.domain = s[1];
			xmppConnection.password = password;
			xmppConnection.addEventListener(LoginEvent.LOGIN, onLogin);
			xmppConnection.addEventListener(XIFFErrorEvent.XIFF_ERROR, onError);
		}
		
		
		public function setupMessageHanlder(messageHandler:Function):void {
			xmppConnection.addEventListener(MessageEvent.MESSAGE, messageHandler);
		}
		
		
		public function setupPresenceHanlder(presenceHandler:Function):void {
			xmppConnection.addEventListener(PresenceEvent.PRESENCE, presenceHandler);
		}
		
		
		public  function connect():void {
			xmppConnection.connect();
		}
		
		
		/**
		 * Used to send a message to the phenomena pod.
		 * 
		 * @param message Message to be sent
		 */
		public function send(message:String):void {
			var m:Message = new Message(new EscapedJID(podId));
			m.from = new EscapedJID(xmppConnection.username);
			m.body = message;
			xmppConnection.send(m);
		}
		
		
		/**
		 * Used to send a message to a particular client.
		 *
		 * @param dest JID of the client that needs to receive the message 
		 * @param message Message to be sent
		 */
		public function sendTo(message:String, dest:String):void {
			var m:Message = new Message(new EscapedJID(dest));
			m.from = new EscapedJID(xmppConnection.username);
			m.body = message;
			xmppConnection.send(m);
		}
		
		
		public function getStatus():Boolean {
			return xmppConnection.isLoggedIn();
		}
		
		
		private function onLogin(e:LoginEvent):void {
			var pres:Presence = new Presence();
			xmppConnection.send(pres);
		}
		
		
		private function onError(e:XIFFErrorEvent):void {
			trace(e. errorType + ": " + e.errorMessage);
		}
		
	}
}