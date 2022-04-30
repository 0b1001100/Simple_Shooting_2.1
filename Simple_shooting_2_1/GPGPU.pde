import org.jocl.*;

boolean canGPGPU;
boolean useGPGPU=false;

cl_device_id[] device = new cl_device_id[1];
cl_context context;
cl_command_queue queue;
cl_program program;
cl_platform_id[] platform = new cl_platform_id[1];
cl_kernel kernel;
cl_event profile_event = new cl_event();

void initGPGPU(){
  CL.clGetPlatformIDs(1, platform, null);
  int err=CL.clGetDeviceIDs(platform[0],CL.CL_DEVICE_TYPE_GPU,1,device,null);
  canGPGPU=!(err==CL.CL_DEVICE_NOT_FOUND);
}
