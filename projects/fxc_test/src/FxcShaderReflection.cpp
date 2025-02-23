// ShaderReflection.cpp : Defines the entry point for the application.
//

#include "FxcShaderReflection.h"
#include "d3dcompiler.h"
#include <cassert>
#include <filesystem>
#include <fstream>
#include <vector>
#include <wrl.h>

using namespace std;
using Microsoft::WRL::ComPtr;

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

std::string ReadFileToString(const std::string& filePath) {
    std::ifstream file(filePath);
    if (!file.is_open()) {
        return "";
    }
    std::ostringstream ss;
    ss << file.rdbuf();
    file.close();
    return ss.str();
}

std::string D3DShaderInputTypeToString(D3D_SHADER_INPUT_TYPE type) {
    switch (type) {
        case D3D_SIT_CBUFFER: return "D3D_SIT_CBUFFER";
        case D3D_SIT_TBUFFER: return "D3D_SIT_TBUFFER";
        case D3D_SIT_TEXTURE: return "D3D_SIT_TEXTURE";
        case D3D_SIT_SAMPLER: return "D3D_SIT_SAMPLER";
        case D3D_SIT_UAV_RWTYPED: return "D3D_SIT_UAV_RWTYPED";
        case D3D_SIT_STRUCTURED: return "D3D_SIT_STRUCTURED";
        case D3D_SIT_UAV_RWSTRUCTURED: return "D3D_SIT_UAV_RWSTRUCTURED";
        case D3D_SIT_BYTEADDRESS: return "D3D_SIT_BYTEADDRESS";
        case D3D_SIT_UAV_RWBYTEADDRESS: return "D3D_SIT_UAV_RWBYTEADDRESS";
        case D3D_SIT_UAV_APPEND_STRUCTURED: return "D3D_SIT_UAV_APPEND_STRUCTURED";
        case D3D_SIT_UAV_CONSUME_STRUCTURED: return "D3D_SIT_UAV_CONSUME_STRUCTURED";
        case D3D_SIT_UAV_RWSTRUCTURED_WITH_COUNTER: return "D3D_SIT_UAV_RWSTRUCTURED_WITH_COUNTER";
        case D3D_SIT_RTACCELERATIONSTRUCTURE: return "D3D_SIT_RTACCELERATIONSTRUCTURE";
        case D3D_SIT_UAV_FEEDBACKTEXTURE: return "D3D_SIT_UAV_FEEDBACKTEXTURE";
        // case D3D10_SIT_CBUFFER: return "D3D10_SIT_CBUFFER";
        // case D3D10_SIT_TBUFFER: return "D3D10_SIT_TBUFFER";
        // case D3D10_SIT_TEXTURE: return "D3D10_SIT_TEXTURE";
        // case D3D10_SIT_SAMPLER: return "D3D10_SIT_SAMPLER";
        // case D3D11_SIT_UAV_RWTYPED: return "D3D11_SIT_UAV_RWTYPED";
        // case D3D11_SIT_STRUCTURED: return "D3D11_SIT_STRUCTURED";
        // case D3D11_SIT_UAV_RWSTRUCTURED: return "D3D11_SIT_UAV_RWSTRUCTURED";
        // case D3D11_SIT_BYTEADDRESS: return "D3D11_SIT_BYTEADDRESS";
        // case D3D11_SIT_UAV_RWBYTEADDRESS: return "D3D11_SIT_UAV_RWBYTEADDRESS";
        // case D3D11_SIT_UAV_APPEND_STRUCTURED: return "D3D11_SIT_UAV_APPEND_STRUCTURED";
        // case D3D11_SIT_UAV_CONSUME_STRUCTURED: return "D3D11_SIT_UAV_CONSUME_STRUCTURED";
        // case D3D11_SIT_UAV_RWSTRUCTURED_WITH_COUNTER: return "D3D11_SIT_UAV_RWSTRUCTURED_WITH_COUNTER";
        default: return "UNKNOWN_D3D_SHADER_INPUT_TYPE";
    }
}

std::string D3DSrvDimensionToString(D3D_SRV_DIMENSION dimension) {
    switch (dimension) {
        case D3D_SRV_DIMENSION_UNKNOWN: return "D3D_SRV_DIMENSION_UNKNOWN";
        case D3D_SRV_DIMENSION_BUFFER: return "D3D_SRV_DIMENSION_BUFFER";
        case D3D_SRV_DIMENSION_TEXTURE1D: return "D3D_SRV_DIMENSION_TEXTURE1D";
        case D3D_SRV_DIMENSION_TEXTURE1DARRAY: return "D3D_SRV_DIMENSION_TEXTURE1DARRAY";
        case D3D_SRV_DIMENSION_TEXTURE2D: return "D3D_SRV_DIMENSION_TEXTURE2D";
        case D3D_SRV_DIMENSION_TEXTURE2DARRAY: return "D3D_SRV_DIMENSION_TEXTURE2DARRAY";
        case D3D_SRV_DIMENSION_TEXTURE2DMS: return "D3D_SRV_DIMENSION_TEXTURE2DMS";
        case D3D_SRV_DIMENSION_TEXTURE2DMSARRAY: return "D3D_SRV_DIMENSION_TEXTURE2DMSARRAY";
        case D3D_SRV_DIMENSION_TEXTURE3D: return "D3D_SRV_DIMENSION_TEXTURE3D";
        case D3D_SRV_DIMENSION_TEXTURECUBE: return "D3D_SRV_DIMENSION_TEXTURECUBE";
        case D3D_SRV_DIMENSION_TEXTURECUBEARRAY: return "D3D_SRV_DIMENSION_TEXTURECUBEARRAY";
        case D3D_SRV_DIMENSION_BUFFEREX: return "D3D_SRV_DIMENSION_BUFFEREX";
        // case D3D10_SRV_DIMENSION_UNKNOWN: return "D3D10_SRV_DIMENSION_UNKNOWN";
        // case D3D10_SRV_DIMENSION_BUFFER: return "D3D10_SRV_DIMENSION_BUFFER";
        // case D3D10_SRV_DIMENSION_TEXTURE1D: return "D3D10_SRV_DIMENSION_TEXTURE1D";
        // case D3D10_SRV_DIMENSION_TEXTURE1DARRAY: return "D3D10_SRV_DIMENSION_TEXTURE1DARRAY";
        // case D3D10_SRV_DIMENSION_TEXTURE2D: return "D3D10_SRV_DIMENSION_TEXTURE2D";
        // case D3D10_SRV_DIMENSION_TEXTURE2DARRAY: return "D3D10_SRV_DIMENSION_TEXTURE2DARRAY";
        // case D3D10_SRV_DIMENSION_TEXTURE2DMS: return "D3D10_SRV_DIMENSION_TEXTURE2DMS";
        // case D3D10_SRV_DIMENSION_TEXTURE2DMSARRAY: return "D3D10_SRV_DIMENSION_TEXTURE2DMSARRAY";
        // case D3D10_SRV_DIMENSION_TEXTURE3D: return "D3D10_SRV_DIMENSION_TEXTURE3D";
        // case D3D10_SRV_DIMENSION_TEXTURECUBE: return "D3D10_SRV_DIMENSION_TEXTURECUBE";
        // case D3D10_1_SRV_DIMENSION_UNKNOWN: return "D3D10_1_SRV_DIMENSION_UNKNOWN";
        // case D3D10_1_SRV_DIMENSION_BUFFER: return "D3D10_1_SRV_DIMENSION_BUFFER";
        // case D3D10_1_SRV_DIMENSION_TEXTURE1D: return "D3D10_1_SRV_DIMENSION_TEXTURE1D";
        // case D3D10_1_SRV_DIMENSION_TEXTURE1DARRAY: return "D3D10_1_SRV_DIMENSION_TEXTURE1DARRAY";
        // case D3D10_1_SRV_DIMENSION_TEXTURE2D: return "D3D10_1_SRV_DIMENSION_TEXTURE2D";
        // case D3D10_1_SRV_DIMENSION_TEXTURE2DARRAY: return "D3D10_1_SRV_DIMENSION_TEXTURE2DARRAY";
        // case D3D10_1_SRV_DIMENSION_TEXTURE2DMS: return "D3D10_1_SRV_DIMENSION_TEXTURE2DMS";
        // case D3D10_1_SRV_DIMENSION_TEXTURE2DMSARRAY: return "D3D10_1_SRV_DIMENSION_TEXTURE2DMSARRAY";
        // case D3D10_1_SRV_DIMENSION_TEXTURE3D: return "D3D10_1_SRV_DIMENSION_TEXTURE3D";
        // case D3D10_1_SRV_DIMENSION_TEXTURECUBE: return "D3D10_1_SRV_DIMENSION_TEXTURECUBE";
        // case D3D10_1_SRV_DIMENSION_TEXTURECUBEARRAY: return "D3D10_1_SRV_DIMENSION_TEXTURECUBEARRAY";
        // case D3D11_SRV_DIMENSION_UNKNOWN: return "D3D11_SRV_DIMENSION_UNKNOWN";
        // case D3D11_SRV_DIMENSION_BUFFER: return "D3D11_SRV_DIMENSION_BUFFER";
        // case D3D11_SRV_DIMENSION_TEXTURE1D: return "D3D11_SRV_DIMENSION_TEXTURE1D";
        // case D3D11_SRV_DIMENSION_TEXTURE1DARRAY: return "D3D11_SRV_DIMENSION_TEXTURE1DARRAY";
        // case D3D11_SRV_DIMENSION_TEXTURE2D: return "D3D11_SRV_DIMENSION_TEXTURE2D";
        // case D3D11_SRV_DIMENSION_TEXTURE2DARRAY: return "D3D11_SRV_DIMENSION_TEXTURE2DARRAY";
        // case D3D11_SRV_DIMENSION_TEXTURE2DMS: return "D3D11_SRV_DIMENSION_TEXTURE2DMS";
        // case D3D11_SRV_DIMENSION_TEXTURE2DMSARRAY: return "D3D11_SRV_DIMENSION_TEXTURE2DMSARRAY";
        // case D3D11_SRV_DIMENSION_TEXTURE3D: return "D3D11_SRV_DIMENSION_TEXTURE3D";
        // case D3D11_SRV_DIMENSION_TEXTURECUBE: return "D3D11_SRV_DIMENSION_TEXTURECUBE";
        // case D3D11_SRV_DIMENSION_TEXTURECUBEARRAY: return "D3D11_SRV_DIMENSION_TEXTURECUBEARRAY";
        // case D3D11_SRV_DIMENSION_BUFFEREX: return "D3D11_SRV_DIMENSION_BUFFEREX";
        default: return "UNKNOWN_D3D_SRV_DIMENSION";
    }
}

int main() {
    std::string shaderPath        = "../../../shaders/SimpleShader.hlsl";
    std::string extraShaderSource = ReadFileToString(shaderPath);
    std::string shaderEntryPoint  = "PSMain";
    // >= _6_0 (error)
    std::string shaderTargetLevel = "ps_5_0";

    ComPtr<ID3DBlob> pBlob;
    ComPtr<ID3DBlob> pErrorBlob;
    uint32_t         shader_size = (uint32_t)extraShaderSource.size();
    auto             hr =
        D3DCompile2(extraShaderSource.c_str(), shader_size, nullptr, nullptr,
                    nullptr, shaderEntryPoint.c_str(), shaderTargetLevel.c_str(), 0, 0, 0, nullptr, 0, pBlob.GetAddressOf(), pErrorBlob.GetAddressOf());

    ComPtr<ID3D12ShaderReflection> pShaderReflection;
    if (hr != S_OK) {
        if (pErrorBlob) {
            char*       c_error_messages = static_cast<char*>(pErrorBlob->GetBufferPointer());
            std::string error_messages   = std::string(c_error_messages);
            cout << error_messages << endl;
        }
        cout << "Compiling Shader failed!" << endl;
        return 0;
    }
    else {
        hr = D3DReflect(pBlob->GetBufferPointer(), pBlob->GetBufferSize(), IID_PPV_ARGS(pShaderReflection.GetAddressOf()));
    }

    if (hr == S_OK) {
        D3D12_SHADER_DESC desc;
        pShaderReflection->GetDesc(&desc);

        auto const_buffer_count = desc.ConstantBuffers;
        for (uint32_t i = 0; i < const_buffer_count; ++i) {
            auto                     cbuffer = pShaderReflection->GetConstantBufferByIndex(i);
            D3D12_SHADER_BUFFER_DESC buffer_desc;
            cbuffer->GetDesc(&buffer_desc);
            auto const_buffer = pShaderReflection->GetConstantBufferByName(buffer_desc.Name);
            assert(cbuffer == const_buffer);

            cout << "Constant Buffer: " << buffer_desc.Name << " with size: " << buffer_desc.Size << " with Var count: " << buffer_desc.Variables << endl;
            auto var_count = buffer_desc.Variables;
            for (uint32_t j = 0; j < var_count; ++j) {
                auto                       var = const_buffer->GetVariableByIndex(j);
                D3D12_SHADER_VARIABLE_DESC var_desc;
                var->GetDesc(&var_desc);
                cout << "Variable Name:	 " << var_desc.Name << endl;
                cout << "	StartOffset: " << var_desc.StartOffset << endl;
                cout << "	Size:		 " << var_desc.Size << endl;
                cout << "	uFlags:		 " << var_desc.uFlags << endl;
                cout << endl;
            }
        }

        cout << "Bound Resource Count: " << desc.BoundResources << endl;
        auto binding_count = desc.BoundResources;
        for (uint32_t i = 0; i < binding_count; ++i) {
            D3D12_SHADER_INPUT_BIND_DESC desc;
            auto                         binding = pShaderReflection->GetResourceBindingDesc(i, &desc);
            cout << "Name: " << desc.Name << endl;
            cout << "	Type:		" << D3DShaderInputTypeToString(desc.Type) << endl;
            cout << "	Dimension:	" << D3DSrvDimensionToString(desc.Dimension) << endl;
            cout << "	BindCount:	" << desc.BindCount << endl;
            cout << "	BindPoint:	" << desc.BindPoint << endl;
            cout << "	Space:		" << desc.Space << endl;
            cout << "	NumSamples: " << desc.NumSamples << endl;
        }
    }
    else {
        cout << "FAILED: Cannot get reflection data!!!" << endl;
    }

    return 0;
}
