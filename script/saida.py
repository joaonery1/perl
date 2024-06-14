
"""
    ************************************************************************
    ***                                                                  ***
    ***                Source code generated by cl2py.pl                 ***
    ***                                                                  ***
    ***                        Please do not edit                        ***
    ***                                                                  ***
    ************************************************************************
"""
#!/usr/bin/python3 python3

# OPENCL LIBRARY
import pyopencl as cl

# VGL LIBRARYS
import vgl_lib as vl

#TO WORK WITH MAIN
import numpy as np

"""
    /** Erosion of src image by mask. Result is stored in dst image.

  */    
"""
def vglClDilate(img_input, img_output, convolution_window, window_size_x, window_size_y):

    vl.vglCheckContext(img_input, vl.VGL_CL_CONTEXT())
    vl.vglCheckContext(img_output, vl.VGL_CL_CONTEXT())
    # EVALUATING IF convolution_window IS IN CORRECT TYPE
    try:
        mobj_convolution_window = cl.Buffer(vl.get_ocl().context, cl.mem_flags.READ_ONLY, convolution_window.nbytes)
        cl.enqueue_copy(vl.get_ocl().commandQueue, mobj_convolution_window, convolution_window.tobytes(), is_blocking=True)
        convolution_window = mobj_convolution_window
    except Exception as e:
        print("vglClConvolution: Error!! Impossible to convert convolution_window to cl.Buffer object.")
        print(str(e))
        exit()
    # EVALUATING IF window_size_x IS IN CORRECT TYPE
    if( not isinstance(window_size_x, np.uint32) ):
        print("vglClConvolution: Warning: window_size_x not np.uint32! Trying to convert...")
        try:
            window_size_x = np.uint32(window_size_x)
        except Exception as e:
            print("vglClConvolution: Error!! Impossible to convert window_size_x as a np.uint32 object.")
            print(str(e))
            exit()
    # EVALUATING IF window_size_y IS IN CORRECT TYPE
    if( not isinstance(window_size_y, np.uint32) ):
        print("vglClConvolution: Warning: window_size_y not np.uint32! Trying to convert...")
        try:
            window_size_y = np.uint32(window_size_y)
        except Exception as e:
            print("vglClConvolution: Error!! Impossible to convert window_size_y as a np.uint32 object.")
            print(str(e))
            exit()

    _program = vl.get_ocl_context().get_compiled_kernel("CL/vglClDilate.cl", "vglClDilate")
    _kernel = _program.vglClDilate

    _kernel.set_arg(0, img_input.get_oclPtr())
    _kernel.set_arg(1, img_output.get_oclPtr())
    _kernel.set_arg(2, mobj_convolution_window)
    _kernel.set_arg(3, window_size_x)
    _kernel.set_arg(4, window_size_y)

    # THIS IS A BLOCKING COMMAND. IT EXECUTES THE KERNEL.
    cl.enqueue_nd_range_kernel(vl.get_ocl().commandQueue, _kernel, img_input.get_oclPtr().shape, None)

    mobj_convolution_window = None
    vl.vglSetContext(img_output, vl.VGL_CL_CONTEXT())

"""
    /** Erosion of src image by mask. Result is stored in dst image.

  */    
"""
def vglClErode(img_input, img_output, convolution_window, window_size_x, window_size_y):

    vl.vglCheckContext(img_input, vl.VGL_CL_CONTEXT())
    vl.vglCheckContext(img_output, vl.VGL_CL_CONTEXT())
    # EVALUATING IF convolution_window IS IN CORRECT TYPE
    try:
        mobj_convolution_window = cl.Buffer(vl.get_ocl().context, cl.mem_flags.READ_ONLY, convolution_window.nbytes)
        cl.enqueue_copy(vl.get_ocl().commandQueue, mobj_convolution_window, convolution_window.tobytes(), is_blocking=True)
        convolution_window = mobj_convolution_window
    except Exception as e:
        print("vglClConvolution: Error!! Impossible to convert convolution_window to cl.Buffer object.")
        print(str(e))
        exit()
    # EVALUATING IF window_size_x IS IN CORRECT TYPE
    if( not isinstance(window_size_x, np.uint32) ):
        print("vglClConvolution: Warning: window_size_x not np.uint32! Trying to convert...")
        try:
            window_size_x = np.uint32(window_size_x)
        except Exception as e:
            print("vglClConvolution: Error!! Impossible to convert window_size_x as a np.uint32 object.")
            print(str(e))
            exit()
    # EVALUATING IF window_size_y IS IN CORRECT TYPE
    if( not isinstance(window_size_y, np.uint32) ):
        print("vglClConvolution: Warning: window_size_y not np.uint32! Trying to convert...")
        try:
            window_size_y = np.uint32(window_size_y)
        except Exception as e:
            print("vglClConvolution: Error!! Impossible to convert window_size_y as a np.uint32 object.")
            print(str(e))
            exit()

    _program = vl.get_ocl_context().get_compiled_kernel("CL/vglClErode.cl", "vglClErode")
    _kernel = _program.vglClErode

    _kernel.set_arg(0, img_input.get_oclPtr())
    _kernel.set_arg(1, img_output.get_oclPtr())
    _kernel.set_arg(2, mobj_convolution_window)
    _kernel.set_arg(3, window_size_x)
    _kernel.set_arg(4, window_size_y)

    # THIS IS A BLOCKING COMMAND. IT EXECUTES THE KERNEL.
    cl.enqueue_nd_range_kernel(vl.get_ocl().commandQueue, _kernel, img_input.get_oclPtr().shape, None)

    mobj_convolution_window = None
    vl.vglSetContext(img_output, vl.VGL_CL_CONTEXT())

"""
    /** Threshold of src image by float parameter. if the pixel is below thresh,
    the output is 0, else, the output is top. Result is stored in dst image.
  */    
"""
def vglClThreshold(src, dst, thresh, top = 1.0):

    vl.vglCheckContext(src, vl.VGL_CL_CONTEXT())
    vl.vglCheckContext(dst, vl.VGL_CL_CONTEXT())
    # EVALUATING IF thresh IS IN CORRECT TYPE
    if( not isinstance(thresh, np.float32) ):
        print("vglClConvolution: Warning: thresh not np.float32! Trying to convert...")
        try:
            thresh = np.float32(thresh)
        except Exception as e:
            print("vglClConvolution: Error!! Impossible to convert thresh as a np.float32 object.")
            print(str(e))
            exit()
    # EVALUATING IF top IS IN CORRECT TYPE
    if( not isinstance(top, np.float32) ):
        print("vglClConvolution: Warning: top not np.float32! Trying to convert...")
        try:
            top = np.float32(top)
        except Exception as e:
            print("vglClConvolution: Error!! Impossible to convert top as a np.float32 object.")
            print(str(e))
            exit()

    _program = vl.get_ocl_context().get_compiled_kernel("CL/vglClThreshold.cl", "vglClThreshold")
    _kernel = _program.vglClThreshold

    _kernel.set_arg(0, src.get_oclPtr())
    _kernel.set_arg(1, dst.get_oclPtr())
    _kernel.set_arg(2, thresh)
    _kernel.set_arg(3, top)

    # THIS IS A BLOCKING COMMAND. IT EXECUTES THE KERNEL.
    cl.enqueue_nd_range_kernel(vl.get_ocl().commandQueue, _kernel, src.get_oclPtr().shape, None)

    vl.vglSetContext(dst, vl.VGL_CL_CONTEXT())

