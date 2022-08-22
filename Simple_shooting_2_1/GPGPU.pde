import java.net.URL;
import org.jocl.*;

int data_size;
int[] pixelBuffer;

boolean canGPGPU;
boolean useGPGPU=false;
boolean doGPGPU;

cl_device_id[] device = new cl_device_id[1];
cl_context context;
cl_command_queue queue;
cl_program program;
cl_platform_id[] platform = new cl_platform_id[1];
cl_kernel kernel;
cl_event profile_event = new cl_event();
cl_mem input_pixel;
cl_mem output_pixel;
final String KERNEL_PATH = ".\\data\\OpenCL\\Merge.cl";
final String FUNC = "merge";

void initGPGPU(){
  CL.clGetPlatformIDs(1,platform,null);
  int err=CL.clGetDeviceIDs(platform[0],CL.CL_DEVICE_TYPE_GPU,1,device,null);
  canGPGPU=!(err==CL.CL_DEVICE_NOT_FOUND);
  if(canGPGPU){
    context=CL.clCreateContext(null, 1, device, null, null, null);
    doGPGPU=useGPGPU;
  }else{
    doGPGPU=false;
  }
  CL.setExceptionsEnabled(true);
}

void initMergeGPGPU() throws Exception{
  StringBuffer sb = new StringBuffer();
  URL resource = new URL("file:/"+sketchPath().replace("\\","/")+KERNEL_PATH);
  String path = Paths.get(resource.toURI()).toFile().getAbsolutePath();
  Scanner sc = new Scanner(new File(path));
  while(sc.hasNext()) {
    sb.append(sc.nextLine()+"\n");
  }
  int[] errPtr=new int[1];
  program=CL.clCreateProgramWithSource(context,1,new String[]{sb.toString()},null,errPtr);
  if(errPtr[0]<0){
    println("clCreateProgramWithSource",errPtr[0]);
  }
  int err=CL.clBuildProgram(program,0,null,null,null,null);
  if(err<0) {
    println("clBuildProgram",err);
  }
  queue=CL.clCreateCommandQueue(context,device[0],0,null);
  kernel=CL.clCreateKernel(program,FUNC,null);
}

void setPixelData(){
  data_size=width*height*(drawNumber+1);
  input_pixel=CL.clCreateBuffer(context,CL.CL_MEM_READ_WRITE,Sizeof.cl_int*data_size,null,null);
  output_pixel=CL.clCreateBuffer(context,CL.CL_MEM_READ_WRITE,Sizeof.cl_int*width*height,null,null);
  CL.clSetKernelArg(kernel,0,Sizeof.cl_mem,Pointer.to(input_pixel));
  CL.clSetKernelArg(kernel,1,Sizeof.cl_mem,Pointer.to(output_pixel));
  CL.clEnqueueWriteBuffer(queue,input_pixel,CL.CL_TRUE,0,Sizeof.cl_int*data_size,Pointer.to(pixelBuffer),0,null,null);
}

void executeMerge(){
  CL.clEnqueueNDRangeKernel(queue,kernel,3,null,new long[]{width,height,drawNumber+1},null,0,null,profile_event);
}

void getPixelData(){
  CL.clFinish(queue);
  CL.clEnqueueReadBuffer(queue,output_pixel,CL.CL_TRUE,0,Sizeof.cl_int*data_size,Pointer.to(pixels),0,null,null);
  CL.clReleaseMemObject(input_pixel);
  CL.clReleaseMemObject(output_pixel);
}

void print_error(String src_msg,int err){
  final String[] err_msg = new String[]{
    "CL_SUCCESS",
    "CL_DEVICE_NOT_FOUND",
    "CL_DEVICE_NOT_AVAILABLE",
    "CL_COMPILER_NOT_AVAILABLE",
    "CL_MEM_OBJECT_ALLOCATION_FAILURE",
    "CL_OUT_OF_RESOURCES",
    "CL_OUT_OF_HOST_MEMORY",
    "CL_PROFILING_INFO_NOT_AVAILABLE",
    "CL_MEM_COPY_OVERLAP",
    "CL_IMAGE_FORMAT_MISMATCH",
    "CL_IMAGE_FORMAT_NOT_SUPPORTED",
    "CL_BUILD_PROGRAM_FAILURE",
    "CL_MAP_FAILURE",
    "CL_MISALIGNED_SUB_BUFFER_OFFSET",
    "CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST",
    "CL_COMPILE_PROGRAM_FAILURE     ",
    "CL_LINKER_NOT_AVAILABLE",
    "CL_LINK_PROGRAM_FAILURE",
    "CL_DEVICE_PARTITION_FAILED",
    "CL_KERNEL_ARG_INFO_NOT_AVAILABLE",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "CL_INVALID_VALUE",
    "CL_INVALID_DEVICE_TYPE",
    "CL_INVALID_PLATFORM",
    "CL_INVALID_DEVICE",
    "CL_INVALID_CONTEXT",
    "CL_INVALID_QUEUE_PROPERTIES",
    "CL_INVALID_COMMAND_QUEUE",
    "CL_INVALID_HOST_PTR",
    "CL_INVALID_MEM_OBJECT",
    "CL_INVALID_IMAGE_FORMAT_DESCRIPTOR",
    "CL_INVALID_IMAGE_SIZE",
    "CL_INVALID_SAMPLER",
    "CL_INVALID_BINARY",
    "CL_INVALID_BUILD_OPTIONS",
    "CL_INVALID_PROGRAM",
    "CL_INVALID_PROGRAM_EXECUTABLE",
    "CL_INVALID_KERNEL_NAME",
    "CL_INVALID_KERNEL_DEFINITION",
    "CL_INVALID_KERNEL",
    "CL_INVALID_ARG_INDEX",
    "CL_INVALID_ARG_VALUE",
    "CL_INVALID_ARG_SIZE",
    "CL_INVALID_KERNEL_ARGS",
    "CL_INVALID_WORK_DIMENSION",
    "CL_INVALID_WORK_GROUP_SIZE",
    "CL_INVALID_WORK_ITEM_SIZE",
    "CL_INVALID_GLOBAL_OFFSET",
    "CL_INVALID_EVENT_WAIT_LIST",
    "CL_INVALID_EVENT",
    "CL_INVALID_OPERATION",
    "CL_INVALID_GL_OBJECT",
    "CL_INVALID_BUFFER_SIZE",
    "CL_INVALID_MIP_LEVEL",
    "CL_INVALID_GLOBAL_WORK_SIZE",
    "CL_INVALID_PROPERTY",
    "CL_INVALID_IMAGE_DESCRIPTOR",
    "CL_INVALID_COMPILER_OPTIONS",
    "CL_INVALID_LINKER_OPTIONS",
    "CL_INVALID_DEVICE_PARTITION_COUNT",
  };
  int index = -err;
  if(err!=CL.CL_SUCCESS){
    println("Failed Message: %s - Error Code: %d\n", src_msg, err, err_msg[index]);
  }
}
