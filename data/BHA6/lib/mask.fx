// 引擎设置的参数，不可修改

SamplerState screen_texture_sampler : register(s4); // RenderTarget 纹理的采样器
Texture2D screen_texture            : register(t4); // RenderTarget 纹理
cbuffer engine_data : register(b1)
{
    float4 screen_texture_size; // 纹理大小
    float4 viewport;            // 视口
};

// 用户传递的浮点参数
// 由多个 float4 组成，且 float4 是最小单元，最多可传递 8 个 float4

cbuffer user_data : register(b0)
{
    float4   color;
};

SamplerState mask_sampler : register(s0);
Texture2D    mask_texture : register(t0);

// 用户传递的纹理和采样器参数，可用槽位 0 到 3

// 为了方便使用，可以定义一些宏


// 不变量

static const float my_PI = 3.14159265f;

// 主函数

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

PS_Output main(PS_Input input)
{
    float4 tex_col = screen_texture.Sample(screen_texture_sampler, input.uv);
    float4 mask_col = mask_texture.Sample(mask_sampler, input.uv);
    tex_col.a *= mask_col.a;
    tex_col.xyz = tex_col.rgb*tex_col.a;

    PS_Output output;
    output.col = tex_col;
    return output;
}