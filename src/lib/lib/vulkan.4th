library> libvulkan.so
import> vkEnumerateInstanceLayerProperties 1 vkEnumerateInstanceLayerProperties 2
import> vkEnumerateInstanceExtensionProperties 1 vkEnumerateInstanceExtensionProperties 3
import> vkCreateInstance 1 vkCreateInstance 3
import> vkDestroyInstance 0 vkDestroyInstance 2
import> vkGetInstanceProcAddr 1 vkGetInstanceProcAddr 2
import> vkEnumeratePhysicalDevices 1 vkEnumeratePhysicalDevices 3
( import> vkCreateDebugReportCallbackEXT 1 vkCreateDebugReportCallbackEXT 4 )

0 const> VK_STRUCTURE_TYPE_APPLICATION_INFO
1 const> VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO

256 const> VK_MAX_EXTENSION_NAME_SIZE
256 const> VK_MAX_DESCRIPTION_SIZE

alias> VkPhysicalDevice pointer<any>

struct: VkLayerProperties
uint<8> VK_MAX_EXTENSION_NAME_SIZE seq-field: layerName
uint<32> field: specVersion
uint<32> field: implementationVersion
uint<8> VK_MAX_DESCRIPTION_SIZE seq-field: description

alias> VkStructureType uint<32>

struct: VkApplicationInfo
VkStructureType field: sType
   pointer<any> field: pNext
   pointer<any> field: pApplicationName
       uint<32> field: applicationVersion
   pointer<any> field: pEngineName
       uint<32> field: engineVersion
       uint<32> field: apiVersion

alias> VkInstanceCreateFlags uint<32>

struct: VkInstanceCreateInfo
VkStructureType field: sType
   pointer<any> field: pNext
VkInstanceCreateFlags field: flags
   pointer<any> field: pApplicationInfo
       uint<32> field: enabledLayerCount
   pointer<any> field: ppEnabledLayerNames
       uint<32> field: enabledExtensionCount
   pointer<any> field: ppEnabledExtensionNames

def make-vulkan-version ( patch minor major variant )
  arg0 29 bsl
  arg1 22 bsl logior
  arg2 12 bsl logior
  arg3 logior
  4 return1-n
end

0 0 1 0 make-vulkan-version const> VK_API_VERSION_1_0

def vulkan-create-instance
  0 0 0
  VkApplicationInfo make-instance set-local0
  VK_API_VERSION_1_0 local0 VkApplicationInfo -> apiVersion !
  VK_STRUCTURE_TYPE_APPLICATION_INFO local0 VkApplicationInfo -> sType !
  VkInstanceCreateInfo make-instance set-local1
  local0 value-of local1 VkInstanceCreateInfo -> pApplicationInfo !
  VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO local1 VkInstanceCreateInfo -> sType !
  0 here 0 local1 value-of vkCreateInstance
  return2
end

def write-vulkan-layer-property
  s" Name: " write-string/2
  arg0 VkLayerProperties . layerName write-string nl
  s" Description: " write-string/2
  arg0 VkLayerProperties . description write-string nl
  s" Spec Version: " write-string/2
  arg0 VkLayerProperties . specVersion @ write-hex-uint nl
  s" Impl Version: " write-string/2
  arg0 VkLayerProperties . implementationVersion @ write-hex-uint nl
  1 return0-n
end

def write-vulkan-layer-properties ( array number counter -- )
  arg0 arg1 uint< UNLESS 3 return0-n THEN
  arg2 arg0 VkLayerProperties sizeof * + write-vulkan-layer-property nl
  arg0 1 + set-arg0 repeat-frame
end

def vulkan-write-layer-props
  0 0
  0 here 0 swap vkEnumerateInstanceLayerProperties drop set-local1
  local1 ,i s"  layer properties" write-string/2 nl nl
  VkLayerProperties sizeof * stack-allot set-local0
  locals cell-size - local0 vkEnumerateInstanceLayerProperties
  local0 local1 0 write-vulkan-layer-properties
end

def vulkan-write-extension-props
  0 0
  0 here 0 swap 0 vkEnumerateInstanceExtensionProperties drop set-local1
  local1 ,i s"  extension properties" write-string/2 nl nl
  VkLayerProperties sizeof * stack-allot set-local0
  local0 locals cell-size - 0 vkEnumerateInstanceExtensionProperties
  local0 local1 0 write-vulkan-layer-properties
end

struct: VkPhysicalDeviceProperties
value 206 seq-field: props

def write-vulkan-physical-device
  arg0 VkPhysicalDeviceProperties sizeof 4 / cmemdump
  1 return0-n
end

def vulkan-write-physical-devices-loop ( device-array number counter -- )
  arg0 arg1 uint< UNLESS 3 return0-n THEN
  arg2 arg0 VkPhysicalDevice sizeof * + write-vulkan-physical-device
  arg0 1 + set-arg0 repeat-frame
end

def vulkan-write-physical-devices ( instance -- )
  0 0
  here 0 swap arg0 vkEnumeratePhysicalDevices .h nl
  ,i s"  physical devices" write-string/2 nl
  local1 VkPhysicalDevice sizeof * stack-allot set-local0
  local0 locals cell-size - arg0 vkEnumeratePhysicalDevices .h nl
  local0 local1 0 vulkan-write-physical-devices-loop
  1 return0-n
end

def vulkan-info
  0
  vulkan-write-layer-props
  vulkan-write-extension-props

  vulkan-create-instance .h nl set-local0
  local0 vulkan-write-physical-devices nl
  0 local0 vkDestroyInstance
end
