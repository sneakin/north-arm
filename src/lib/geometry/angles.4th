def radians->vec2d ( degs -- y x )
  arg0 float32-cos
  arg0 float32-sin set-arg0 return1
end

def radians->degrees ( float<32> -- float<32> )
  arg0 180 int32->float32 float32-mul pi float32-div set-arg0
end

def degrees->radians ( float<32> -- float<32> )
  arg0 pi float32-mul 180 int32->float32 float32-div set-arg0
end

def degrees->vec2d ( float<32> -- y x )
  arg0 degrees->radians radians->vec2d swap set-arg0 return1
end
