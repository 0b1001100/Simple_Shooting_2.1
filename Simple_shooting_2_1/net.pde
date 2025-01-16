import processing.net.*;

Server server;

Client client;

String[] clients=new String[3];

int port=8080;
String name="";

NetValidator netValidator=new NetValidator();

void startServer(int port){
  server=new Server(this,port);
  this.port=port;
}

void startClient(String ip,int port,String name){
  client=new Client(this,ip,port);
  this.port=port;
  this.name=name;
  client.write("handshake:"+name);
  netValidator.handshake();
  new Timer(false).schedule(new TimerTask(){
    void run(){
      if(!netValidator.isSuccess())netValidator.fail();
    }
  },10000);
}

String getIP(){
  return Server.ip();
}

void serverEvent(Server someServer,Client someClient){
  String s = someClient.readStringUntil('\n').trim();
  if(s==null)return;
  if(s.contains("handshake")){
    server.write(s);
  }
}

void clientEvent(Client someClient){
  String s = someClient.readStringUntil('\n').trim();
  if(s==null)return;
  if(s.equals("handshake"+name))netValidator.success();
}

void disconnectEvent(Client someClient){
  
}

class NetValidator{
  ValidationState state=ValidationState.None;
  RoleState role=RoleState.None;
  
  void asServer(){
    role=RoleState.Server;
  }
  
  void asClient(){
    role=RoleState.Client;
  }
  
  void disconnect(){
    role=RoleState.None;
  }
  
  void success(){
    state=ValidationState.Success;
  }
  
  boolean isSuccess(){
    return state==ValidationState.Success;
  }
  
  void handshake(){
    state=ValidationState.Handshake;
  }
  
  boolean isHandshake(){
    return state==ValidationState.Handshake;
  }
  
  void fail(){
    state=ValidationState.Fail;
  }
  
  boolean isFail(){
    return state==ValidationState.Fail;
  }
}

enum ValidationState{
  None,
  Handshake,
  Fail,
  Success
}

enum RoleState{
  None,
  Server,
  Client
}
