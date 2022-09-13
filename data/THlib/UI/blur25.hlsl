SamplerState ScreenTextureSampler : register(s4); // RenderTarget 纹理的采样器
Texture2D ScreenTexture            : register(t4); // RenderTarget 纹理
cbuffer engine_data : register(b1)
{
    float4 screen; // 纹理大小
    float4 viewport;            // 视口
};

static const float inner = 1.0f;//边沿缩进
// 用户传递的参数

cbuffer user_data : register(b0)
{
    float4 data;
};
#define radius data.x
#define offset data.yz
#define alpha data.w

struct PS_Input
{
    float4 sxy : SV_Position;
    float2 uv  : TEXCOORD0;
    float4 col : COLOR0;
};
struct PS_Output
{
    float4 col : SV_Target;
};

float4 GaussianSampler25(float2 uv, float r)
{
    float2 xy = uv * screen.xy;

    float4 TexColor=float4(0.0f,0.0f,0.0f,0.0f);
    float2 SamplerPoint[26];
    float2 Lxy;
    float2 Luv;

    //获得采样点偏移
    //内9个点
    SamplerPoint[1] = float2(-0.5f * r, 0.5f * r);
    SamplerPoint[2] = float2(0.0f * r, 0.5f * r);
    SamplerPoint[3] = float2(0.5f * r, 0.5f * r);
    SamplerPoint[4] = float2(-0.5f * r, 0.0f * r);
    SamplerPoint[5] = float2(0.0f * r, 0.0f * r);
    SamplerPoint[6] = float2(0.5f * r, 0.0f * r);
    SamplerPoint[7] = float2(-0.5f * r, -0.5f * r);
    SamplerPoint[8] = float2(0.0f * r, -0.5f * r);
    SamplerPoint[9] = float2(0.5f * r, -0.5f * r);
    //上5个点
    SamplerPoint[10] = float2(-1.0f * r, 1.0f * r);
    SamplerPoint[11] = float2(-0.5f * r, 1.0f * r);
    SamplerPoint[12] = float2(0.0f * r, 1.0f * r);
    SamplerPoint[13] = float2(0.5f * r, 1.0f * r);
    SamplerPoint[14] = float2(1.0f * r, 1.0f * r);
    //左右6个点
    SamplerPoint[15] = float2(-1.0f * r, 0.5f * r);
    SamplerPoint[16] = float2(1.0f * r, 0.5f * r);
    SamplerPoint[17] = float2(-1.0f * r, 0.0f * r);
    SamplerPoint[18] = float2(1.0f * r, 0.0f * r);
    SamplerPoint[19] = float2(-1.0f * r, -0.5f * r);
    SamplerPoint[20] = float2(1.0f * r, -0.5f * r);
    //下5个点
    SamplerPoint[21] = float2(-1.0f * r, -1.0f * r);
    SamplerPoint[22] = float2(-0.5f * r, -1.0f * r);
    SamplerPoint[23] = float2(0.0f * r, -1.0f * r);
    SamplerPoint[24] = float2(0.5f * r, -1.0f * r);
    SamplerPoint[25] = float2(1.0f * r, -1.0f * r);

    for (int se = 1; se <= 25; se = se + 1)
    {
        Lxy = xy + SamplerPoint[se]; //获得采样点坐标
        Lxy.x = clamp(Lxy.x, viewport.x + inner, viewport.z - inner); //限制采样点x坐标
        Lxy.y = clamp(Lxy.y, viewport.y + inner, viewport.w - inner); //限制采样点y坐标
        Luv = Lxy / screen.xy; //获得采样点uv坐标
        TexColor = TexColor + ScreenTexture.Sample(ScreenTextureSampler, Luv); //得到采样颜色并相加
    }

    return TexColor / 25.0f; //取平均值
}
float4 GaussianSampler49(float2 uv, float r)
{
    float2 xy = uv * screen.xy;

    float ratble[8]={9961.0f,-1.0f,-0.65f,-0.35f,0.0f,0.35f,0.65f,1.0f};
    float4 TexColor=float4(0.0f,0.0f,0.0f,0.0f);
    float2 SamplerPointx[22];
    float2 SamplerPointy[22];
    float2 SamplerPointz[8];
    float2 Lxy;
    float2 Luv;
    float num;

    //获得采样点偏移
    for (int sa = 1; sa <= 7; sa = sa + 1)
    {
        num = ratble[sa];
        SamplerPointx[sa] = float2(-1.0f * r, num * r);
        SamplerPointx[7+sa] = float2(-0.65f * r, num * r);
        SamplerPointx[14+sa] = float2(-0.35f * r, num * r);
        SamplerPointy[sa] = float2(0.0f * r, num * r);
        SamplerPointy[7+sa] = float2(0.35f * r, num * r);
        SamplerPointy[14+sa] = float2(0.65f * r, num * r);
        SamplerPointz[sa] = float2(1.0f * r, num * r);
    }

    for (int se = 1; se <= 21; se = se + 1)
    {
        Lxy = xy + SamplerPointx[se]; //获得采样点坐标
        Lxy.x = clamp(Lxy.x, viewport.x + inner, viewport.z - inner); //限制采样点x坐标
        Lxy.y = clamp(Lxy.y, viewport.y + inner, viewport.w - inner); //限制采样点y坐标
        Luv = Lxy / screen.xy; //获得采样点uv坐标
        TexColor = TexColor + ScreenTexture.Sample(ScreenTextureSampler, Luv); //得到采样颜色并相加
    }
    for (int se = 1; se <= 21; se = se + 1)
    {
        Lxy = xy + SamplerPointy[se]; //获得采样点坐标
        Lxy.x = clamp(Lxy.x, viewport.x + inner, viewport.z - inner); //限制采样点x坐标
        Lxy.y = clamp(Lxy.y, viewport.y + inner, viewport.w - inner); //限制采样点y坐标
        Luv = Lxy / screen.xy; //获得采样点uv坐标
        TexColor = TexColor + ScreenTexture.Sample(ScreenTextureSampler, Luv); //得到采样颜色并相加
    }
    for (int se = 1; se <= 7; se = se + 1)
    {
        Lxy = xy + SamplerPointz[se]; //获得采样点坐标
        Lxy.x = clamp(Lxy.x, viewport.x + inner, viewport.z - inner); //限制采样点x坐标
        Lxy.y = clamp(Lxy.y, viewport.y + inner, viewport.w - inner); //限制采样点y坐标
        Luv = Lxy / screen.xy; //获得采样点uv坐标
        TexColor = TexColor + ScreenTexture.Sample(ScreenTextureSampler, Luv); //得到采样颜色并相加
    }

    return TexColor / 49.0f; //取平均值
}

PS_Output main(PS_Input input)
{
    float4 texColor = GaussianSampler49(input.uv + offset,radius);//获得均值颜色，25点
    //float4 texColor = ScreenTexture.Sample(ScreenTextureSampler, input.uv);
    texColor.rgb *= 0.0f;
    texColor.a *= alpha;

    PS_Output output;
    output.col = texColor;
    return output;
}