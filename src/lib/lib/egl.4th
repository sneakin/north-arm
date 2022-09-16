14 const> EGL-VERSION
library> libEGL.so

( EGL 1.0 )
import> eglChooseConfig 1 eglChooseConfig 5 ( EGLDisplay dpy, const EGLint *attrib_list, EGLConfig *configs, EGLint config_size, EGLint *num_config )
import> eglCopyBuffers 1 eglCopyBuffers 3 ( EGLDisplay dpy, EGLSurface surface, EGLNativePixmapType target )
import> eglCreateContext 1 eglCreateContext 4 ( EGLDisplay dpy, EGLConfig config, EGLContext share_context, const EGLint *attrib_list )
import> eglCreatePbufferSurface 1 eglCreatePbufferSurface 3 ( EGLDisplay dpy, EGLConfig config, const EGLint *attrib_list )
import> eglCreatePixmapSurface 1 eglCreatePixmapSurface 4 ( EGLDisplay dpy, EGLConfig config, EGLNativePixmapType pixmap, const EGLint *attrib_list )
import> eglCreateWindowSurface 1 eglCreateWindowSurface 4 ( EGLDisplay dpy, EGLConfig config, EGLNativeWindowType win, const EGLint *attrib_list )
import> eglDestroyContext 1 eglDestroyContext 2 ( EGLDisplay dpy, EGLContext ctx )
import> eglDestroySurface 1 eglDestroySurface 2 ( EGLDisplay dpy, EGLSurface surface )
import> eglGetConfigAttrib 1 eglGetConfigAttrib 4 ( EGLDisplay dpy, EGLConfig config, EGLint attribute, EGLint *value )
import> eglGetConfigs 1 eglGetConfigs 4 ( EGLDisplay dpy, EGLConfig *configs, EGLint config_size, EGLint *num_config )
import> eglGetCurrentDisplay 1 eglGetCurrentDisplay 0 ( void )
import> eglGetCurrentSurface 1 eglGetCurrentSurface 1 ( EGLint readdraw )
import> eglGetDisplay 1 eglGetDisplay 1 ( EGLNativeDisplayType display_id )
import> eglGetError 1 eglGetError 0 ( void )
import> eglGetProcAddress 1 eglGetProcAddress 1 ( const char *procname )
import> eglInitialize/3 1 eglInitialize 3 ( EGLDisplay dpy, EGLint *major, EGLint *minor )
import> eglMakeCurrent 1 eglMakeCurrent 4 ( EGLDisplay dpy, EGLSurface draw, EGLSurface read, EGLContext ctx )
import> eglQueryContext 1 eglQueryContext 4 ( EGLDisplay dpy, EGLContext ctx, EGLint attribute, EGLint *value )
import> eglQueryString 1 eglQueryString 2 ( EGLDisplay dpy, EGLint name )
import> eglQuerySurface 1 eglQuerySurface 4 ( EGLDisplay dpy, EGLSurface surface, EGLint attribute, EGLint *value )
import> eglSwapBuffers 1 eglSwapBuffers 2 ( EGLDisplay dpy, EGLSurface surface )
import> eglTerminate 1 eglTerminate 1 ( EGLDisplay dpy )
import> eglWaitGL 1 eglWaitGL 0 ( void )
import> eglWaitNative 1 eglWaitNative 1 ( EGLint engine )

( EGL 1.1 )
EGL-VERSION 11 uint>= [IF]
import> eglBindTexImage 1 eglBindTexImage 3 ( EGLDisplay dpy, EGLSurface surface, EGLint buffer )
import> eglReleaseTexImage 1 eglReleaseTexImage 3 ( EGLDisplay dpy, EGLSurface surface, EGLint buffer )
import> eglSurfaceAttrib 1 eglSurfaceAttrib 4 ( EGLDisplay dpy, EGLSurface surface, EGLint attribute, EGLint value )
import> eglSwapInterval 1 eglSwapInterval 2 ( EGLDisplay dpy, EGLint interval )
[THEN]

( EGL 1.2 )
EGL-VERSION 12 uint>= [IF]
import> eglBindAPI 1 eglBindAPI 1 ( EGLenum api )
import> eglQueryAPI 1 eglQueryAPI 0 ( void )
import> eglReleaseThread 1 eglReleaseThread 0 ( void )
import> eglWaitClient 1 eglWaitClient 0 ( void )
import> eglCreatePbufferFromClientBuffer 1 eglCreatePbufferFromClientBuffer 5 ( EGLDisplay dpy, EGLenum buftype, EGLClientBuffer buffer, EGLConfig config, const EGLint *attrib_list )
[THEN]

( EGL 1.4 )
EGL-VERSION 14 uint>= [IF]
import> eglGetCurrentContext 1 eglGetCurrentContext 0 ( void )
[THEN]

( EGL 1.5 )
EGL-VERSION 15 uint>= [IF]
import> eglCreateSync 1 eglCreateSync 3 ( EGLDisplay dpy, EGLenum type, const EGLAttrib *attrib_list )
import> eglDestroySync 1 eglDestroySync 2 ( EGLDisplay dpy, EGLSync sync )
import> eglClientWaitSync 1 eglClientWaitSync 4 ( EGLDisplay dpy, EGLSync sync, EGLint flags, EGLTime timeout )
import> eglGetSyncAttrib 1 eglGetSyncAttrib 4 ( EGLDisplay dpy, EGLSync sync, EGLint attribute, EGLAttrib *value )
import> eglCreateImage 1 eglCreateImage 5 ( EGLDisplay dpy, EGLContext ctx, EGLenum target, EGLClientBuffer buffer, const EGLAttrib *attrib_list )
import> eglDestroyImage 1 eglDestroyImage 2 ( EGLDisplay dpy, EGLImage image )
import> eglGetPlatformDisplay 1 eglGetPlatformDisplay 3 ( EGLenum platform, void *native_display, const EGLAttrib *attrib_list )
import> eglCreatePlatformWindowSurface 1 eglCreatePlatformWindowSurface 4 ( EGLDisplay dpy, EGLConfig config, void *native_window, const EGLAttrib *attrib_list )
import> eglCreatePlatformPixmapSurface 1 eglCreatePlatformPixmapSurface 4 ( EGLDisplay dpy, EGLConfig config, void *native_pixmap, const EGLAttrib *attrib_list )
import> eglWaitSync 1 eglWaitSync 3 ( EGLDisplay dpy, EGLSync sync, EGLint flags )
[THEN]

0 var> EGL-REAL-MAJOR
0 var> EGL-REAL-MINOR

0x3053 const> EGL-VENDOR
0x3054 const> EGL-VERSION

def eglInitialize
  EGL-REAL-MINOR EGL-REAL-MAJOR eglGetCurrentDisplay eglInitialize/3
  EGL-VENDOR eglGetCurrentDisplay eglQueryString ,h espace write-line
  EGL-VERSION eglGetCurrentDisplay eglQueryString ,h espace write-line
  return1
end
