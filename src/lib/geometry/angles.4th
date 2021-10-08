def radians->vec2d ( degs -- y x )
  arg0 float32-sin
  arg0 float32-cos set-arg0 return1
end

def degrees->radians ( float<32> -- float<32> )
  arg0 pi float32-mul 180 int32->float32 float32-div set-arg0
end

def degrees->vec2d ( float<32> -- y x )
  arg0 degrees->radians radians->vec2d swap set-arg0 return1
end
