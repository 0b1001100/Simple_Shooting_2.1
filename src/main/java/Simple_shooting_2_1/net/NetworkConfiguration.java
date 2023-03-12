package Simple_shooting_2_1.net;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.Charset;

public enum NetworkConfiguration {
  INSTANCE;

  private static String global_IP;
  private static String local_IP;

  public static NetworkConfiguration getInstance(){
    init();
    return INSTANCE;
  }

  private static void init(){
    switch(System.getProperty("os.name").toLowerCase()){
      case String s when s.contains("windows"):getWindowsIP();break;
      case String s when s.contains("linux"):break;
      case String s when s.contains("mac"):break;
      default:NetworkConfiguration.global_IP="";break;
    }
  }

  private static void getWindowsIP(){
    //get global IP
    ProcessBuilder builder=new ProcessBuilder("nslookup","myip.opendns.com","208.67.222.222");
    
    try{
      Process process = builder.start();
      try (BufferedReader r = new BufferedReader(new InputStreamReader(process.getInputStream(), Charset.defaultCharset()))) {
          String line;
          while ((line = r.readLine()) != null) {
            if(line.contains("Address")){
              global_IP=line.split(":")[1].trim();
            }
          }
      }
    }catch (IOException e){
      e.printStackTrace();
    }

    //get local IP
  }

  public String getGlobalIP(){
    return global_IP;
  }
}
