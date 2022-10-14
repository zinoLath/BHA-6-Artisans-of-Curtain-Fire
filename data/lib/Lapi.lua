-- THlib export these API into global space
-- THlib 将这些 API 导出到全局

BoxCheck = lstg.BoxCheck
ColliCheck = lstg.ColliCheck
Angle = lstg.Angle
Dist = lstg.Dist
GetV = lstg.GetV
SetV = lstg.SetV
GetAttr = lstg.GetAttr
SetAttr = lstg.SetAttr
DefaultRenderFunc = lstg.DefaultRenderFunc
SetImgState = lstg.SetImgState
SetParState = lstg.SetParState
ParticleStop = lstg.ParticleStop
ParticleFire = lstg.ParticleFire
ParticleGetn = lstg.ParticleGetn
ParticleGetEmission = lstg.ParticleGetEmission
ParticleSetEmission = lstg.ParticleSetEmission
GetSuperPause = lstg.GetSuperPause
SetSuperPause = lstg.SetSuperPause
AddSuperPause = lstg.AddSuperPause
GetCurrentSuperPause = lstg.GetCurrentSuperPause
SetWorldFlag = lstg.SetWorldFlag
IsSameWorld = lstg.IsSameWorld
ActiveWorlds = lstg.ActiveWorlds
SetResLoadInfo = lstg.SetResLoadInfo
SetResourceStatus = lstg.SetResourceStatus
GetResourceStatus = lstg.GetResourceStatus
LoadTexture = lstg.LoadTexture
LoadImage = lstg.LoadImage
LoadAnimation = lstg.LoadAnimation
LoadPS = lstg.LoadPS
LoadSound = lstg.LoadSound
LoadMusic = lstg.LoadMusic
LoadFont = lstg.LoadFont
LoadTTF = lstg.LoadTTF
LoadFX = lstg.LoadFX
LoadModel = lstg.LoadModel
CreateRenderTarget = lstg.CreateRenderTarget
Color = lstg.Color
RemoveResource = lstg.RemoveResource
CheckRes = lstg.CheckRes
EnumRes = lstg.EnumRes
ParticleSystemData = lstg.ParticleSystemData
SetImageState = lstg.SetImageState
SetImageColor = lstg.SetImageColor
SetImageSubColor = lstg.SetImageSubColor
SetImageCenter = lstg.SetImageCenter
SetAnimationScale = lstg.SetAnimationScale
GetAnimationScale = lstg.GetAnimationScale
SetAnimationState = lstg.SetAnimationState
Render = lstg.Render
SetFontState = lstg.SetFontState
CacheTTFString = lstg.CacheTTFString
PlaySound = lstg.PlaySound
StopSound = lstg.StopSound
PauseSound = lstg.PauseSound
ResumeSound = lstg.ResumeSound
MeshData = lstg.MeshData
cos = lstg.cos
tan = lstg.tan
asin = lstg.asin
acos = lstg.acos
atan = lstg.atan
SaveTexture = lstg.SaveTexture
BeginScene = lstg.BeginScene
EndScene = lstg.EndScene
RenderClear = lstg.RenderClear
SetViewport = lstg.SetViewport
SetScissorRect = lstg.SetScissorRect
SetOrtho = lstg.SetOrtho
SetPerspective = lstg.SetPerspective
atan2 = lstg.atan2
Render4V = lstg.Render4V
RenderAnimation = lstg.RenderAnimation
RenderTexture = lstg.RenderTexture
RenderMesh = lstg.RenderMesh
RenderModel = lstg.RenderModel
SetFog = lstg.SetFog
SetZBufferEnable = lstg.SetZBufferEnable
ClearZBuffer = lstg.ClearZBuffer
PushRenderTarget = lstg.PushRenderTarget
PopRenderTarget = lstg.PopRenderTarget
PostEffect = lstg.PostEffect
SetTextureSamplerState = lstg.SetTextureSamplerState
GetVersionNumber = lstg.GetVersionNumber
GetVersionName = lstg.GetVersionName
SetWindowed = lstg.SetWindowed
SetFPS = lstg.SetFPS
GetFPS = lstg.GetFPS
SetVsync = lstg.SetVsync
SetResolution = lstg.SetResolution
Log = lstg.Log
SystemLog = lstg.SystemLog
Print = lstg.Print
DoFile = lstg.DoFile
LoadTextFile = lstg.LoadTextFile
ChangeVideoMode = lstg.ChangeVideoMode
EnumResolutions = lstg.EnumResolutions
EnumGPUs = lstg.EnumGPUs
GetMouseState = lstg.GetMouseState
GetMousePosition = lstg.GetMousePosition
GetMouseWheelDelta = lstg.GetMouseWheelDelta
GetLastKey = lstg.GetLastKey
AfterFrame = lstg.AfterFrame
New = lstg.New
CollisionCheck = lstg.CollisionCheck
Kill = lstg.Kill
IsValid = lstg.IsValid
BoundCheck = lstg.BoundCheck
sin = lstg.sin
Execute = lstg.Execute
FindFiles = lstg.FindFiles
ExtractRes = lstg.ExtractRes
UnloadPack = lstg.UnloadPack
LoadPack = lstg.LoadPack
MessageBox = lstg.MessageBox
SetBGMVolume = lstg.SetBGMVolume
GetMusicState = lstg.GetMusicState
ResumeMusic = lstg.ResumeMusic
PauseMusic = lstg.PauseMusic
StopMusic = lstg.StopMusic
PlayMusic = lstg.PlayMusic
SetSEVolume = lstg.SetSEVolume
GetSoundState = lstg.GetSoundState
SetAnimationCenter = lstg.SetAnimationCenter
GetImageScale = lstg.GetImageScale
SetImageScale = lstg.SetImageScale
GetTextureSize = lstg.GetTextureSize
IsRenderTarget = lstg.IsRenderTarget
RenderRect = lstg.RenderRect
Snapshot = lstg.Snapshot
RenderTTF = lstg.RenderTTF
RenderText = lstg.RenderText
RenderGroupCollider = lstg.RenderGroupCollider
DrawCollider = lstg.DrawCollider
GetKeyState = lstg.GetKeyState
GetnObj = lstg.GetnObj
ObjFrame = lstg.ObjFrame
ObjRender = lstg.ObjRender
SetBound = lstg.SetBound
UpdateXY = lstg.UpdateXY
ResetPool = lstg.ResetPool
ObjList = lstg.ObjList
Del = lstg.Del
GetWorldFlag = lstg.GetWorldFlag
SetTitle = lstg.SetTitle
SetSplash = lstg.SetSplash
BentLaserData = lstg.BentLaserData
Rand = lstg.Rand
StopWatch = lstg.StopWatch

-- Undocumented API, still in experimental
-- 未公开的 API，还处于实验状态

GetSEVolume = lstg.GetSEVolume
SetSESpeed = lstg.SetSESpeed
GetSESpeed = lstg.GetSESpeed
NextObject = lstg.NextObject -- Internal/内部方法
ResetObject = lstg.ResetObject
SetBGMLoop = lstg.SetBGMLoop
GetBGMSpeed = lstg.GetBGMSpeed
SetBGMSpeed = lstg.SetBGMSpeed
GetBGMVolume = lstg.GetBGMVolume
GetMusicFFT = lstg.GetMusicFFT
SetTexturePreMulAlphaState = lstg.SetTexturePreMulAlphaState
ObjTable = lstg.ObjTable -- Internal/内部方法
SetDefaultWindowStyle = lstg.SetDefaultWindowStyle

-- Completely deprecated API, are empty function
-- 彻底废弃的 API，已经是空函数

IsInWorld = lstg.IsInWorld
GetCurrentObject = lstg.GetCurrentObject
UpdateSound = lstg.UpdateSound
PostEffectApply = lstg.PostEffectApply
PostEffectCapture = lstg.PostEffectCapture
ShowSplashWindow = lstg.ShowSplashWindow

function SetFPS(_fps)
    lstg.maxfps = _fps
    lstg.SetFPS(_fps)
end

function Render4Vec(img,v1,v2,v3,v4)
    return Render4V(img,v1.x,v1.y,v1.z,v2.x,v2.y,v2.z,v3.x,v3.y,v3.z,v4.x,v4.y,v4.z)
end
local buf1, buf2, buf3, buf4 = {}, {}, {}, {}
function RenderTextureT(img,blend,
                        v1x,v1y,v1z,v1u,v1v,v1c,
                        v2x,v2y,v2z,v2u,v2v,v2c,
                        v3x,v3y,v3z,v3u,v3v,v3c,
                        v4x,v4y,v4z,v4u,v4v,v4c)
    buf1[1],buf1[2],buf1[3],buf1[4],buf1[5],buf1[6] = v1x,v1y,v1z,v1u,v1v,v1c
    buf2[1],buf2[2],buf2[3],buf2[4],buf2[5],buf2[6] = v2x,v2y,v2z,v2u,v2v,v2c
    buf3[1],buf3[2],buf3[3],buf3[4],buf3[5],buf3[6] = v3x,v3y,v3z,v3u,v3v,v3c
    buf4[1],buf4[2],buf4[3],buf4[4],buf4[5],buf4[6] = v4x,v4y,v4z,v4u,v4v,v4c
    RenderTexture(img,blend,buf1,buf2,buf3,buf4)
end

do return end
function PostEffect()

end
function PushRenderTarget()

end
function PopRenderTarget()
    
end