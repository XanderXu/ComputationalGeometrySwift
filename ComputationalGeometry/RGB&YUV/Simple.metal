//
//  Simple.metal
//  Chapter6_1
//
//  Created by CoderXu on 2020/10/7.
//

//默认的头文件
#include <metal_stdlib>
using namespace metal;
//与 SceneKit 配合使用时，需要的头文件
#include <SceneKit/scn_metal>


struct VertexInput {
    float3 position [[attribute(SCNVertexSemanticPosition)]];
};

struct ColorInOut
{
    float4 position [[position]];
    float4 color;
};

struct MyNodeData
{
    float4x4 modelViewProjectionTransform;
};


// 顶点着色器函数，输出为 ColorInOut 类型，输入为 VertexInput 类型的变量 in，和 MyNodeData 类型的变量指针 scn_node
vertex ColorInOut vertexShader(VertexInput in [[stage_in]], constant MyNodeData& scn_node [[buffer(0)]])
{
    ColorInOut out;
    // 将模型空间的顶点补全为 float4 类型，进行 MVP 变换
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    // 加 0.5，将坐标从[-0.5～0.5]，转换到[0～1] 以代表颜色
    out.color = float4(in.position + 0.5, 1);
    return out;
}

// 片元着色器函数，输出为 half4，输入为 ColorInOut 类型的变量 in
fragment half4 fragmentShader(ColorInOut in [[stage_in]])
{
    return half4(in.color);
}
