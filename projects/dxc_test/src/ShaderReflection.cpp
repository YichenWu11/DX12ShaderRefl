// ShaderReflection.cpp : Defines the entry point for the application.
//

// #include "ShaderReflection.h"
#include "CommonShader.h"
#include "d3d12shader.h"
#include "dxcapi.h"
#include <cassert>
#include <filesystem>
#include <fstream>
#include <vector>
#include <wrl.h>

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

// this is from DirectXShaderCompiler\include\dxc\DxilContainer\DxilContainer.h
// which is not supposed to be a public header!!!
#define DXIL_FOURCC(ch0, ch1, ch2, ch3) \
    ((uint32_t)(uint8_t)(ch0) | (uint32_t)(uint8_t)(ch1) << 8 | (uint32_t)(uint8_t)(ch2) << 16 | (uint32_t)(uint8_t)(ch3) << 24)

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

void SaveCompiledShaderToFile(ComPtr<IDxcResult> pCompileResult, const std::wstring& filePath) {
    ComPtr<IDxcBlob> pShaderBlob;
    HRESULT          hr = pCompileResult->GetOutput(DXC_OUT_OBJECT, IID_PPV_ARGS(&pShaderBlob), nullptr);
    if (FAILED(hr)) {
        return;
    }

    std::ofstream outFile(filePath, std::ios::binary);
    if (!outFile) {
        return;
    }

    outFile.write(static_cast<const char*>(pShaderBlob->GetBufferPointer()), pShaderBlob->GetBufferSize());
    outFile.close();
}

int main() {
    std::string shaderPath        = "../../../shaders/SimpleShader.hlsl";
    std::string extraShaderSource = ReadFileToString(shaderPath);
    LPCWSTR     shaderEntryPoint  = L"PSMain";
    LPCWSTR     shaderTargetLevel = L"ps_6_2";

    std::string rawDxilPath = "../../../shaders/SimpleShader.dxil";

    std::wstring saveDxilPath = L"../../../shaders/SimpleShader.dxil";

    ComPtr<IDxcUtils> pUtils;
    DxcCreateInstance(CLSID_DxcUtils, IID_PPV_ARGS(pUtils.GetAddressOf()));

    ComPtr<IDxcLibrary> pLibrary;
    DxcCreateInstance(CLSID_DxcLibrary, IID_PPV_ARGS(pLibrary.GetAddressOf()));

    ComPtr<IDxcContainerReflection> pContainer;
    DxcCreateInstance(CLSID_DxcContainerReflection,
                      IID_PPV_ARGS(pContainer.GetAddressOf()));

    // compiler shader, otherwise from raw dxil file
    bool                           compile_shader = true;
    bool                           save_dxil      = false;
    bool                           test_library   = false;
    DxcBuffer                      shaderBuffer;
    std::vector<char>              raw_buffer;
    ComPtr<IDxcBlob>               pReflectionData;
    ComPtr<IDxcBlob>               pShaderBlob;
    ComPtr<ID3D12ShaderReflection> pShaderReflection;

    if (compile_shader) {
        cout << "Getting d3d12 reflection data from code directly" << endl;
        ComPtr<IDxcCompiler3> pCompiler3;
        DxcCreateInstance(CLSID_DxcCompiler,
                          IID_PPV_ARGS(pCompiler3.GetAddressOf()));

        ComPtr<IDxcIncludeHandler> pIncludeHandler;
        pUtils->CreateDefaultIncludeHandler(
            pIncludeHandler.ReleaseAndGetAddressOf());

        std::vector<LPCWSTR> arguments;
        //-E for the entry point (eg. PSMain)
        arguments.push_back(L"-E");
        arguments.push_back(shaderEntryPoint);

        //-T for the target profile (eg. ps_6_2)
        arguments.push_back(L"-T");
        arguments.push_back(shaderTargetLevel);

        // Strip reflection data and pdbs (see later)
        arguments.push_back(L"-Qstrip_debug");
        arguments.push_back(L"-Qstrip_reflect");
        arguments.push_back(L"-enable-16bit-types");

        arguments.push_back(DXC_ARG_WARNINGS_ARE_ERRORS);   //-WX
        arguments.push_back(DXC_ARG_DEBUG);                 //-Zi
        arguments.push_back(DXC_ARG_PACK_MATRIX_ROW_MAJOR); //-Zp

        ComPtr<IDxcBlobEncoding> pSource;
        uint32_t                 shader_size = (uint32_t)extraShaderSource.size();
        pUtils->CreateBlob(extraShaderSource.c_str(), shader_size, CP_UTF8,
                           pSource.GetAddressOf());

        shaderBuffer.Ptr      = pSource->GetBufferPointer();
        shaderBuffer.Size     = pSource->GetBufferSize();
        shaderBuffer.Encoding = 0;

        ComPtr<IDxcResult> pCompileResult;
        auto               hr = pCompiler3->Compile(&shaderBuffer, arguments.data(),
                                                    (uint32_t)arguments.size(), nullptr,
                                                    IID_PPV_ARGS(pCompileResult.GetAddressOf()));

        if (save_dxil) {
            SaveCompiledShaderToFile(pCompileResult, saveDxilPath);
        }

        if (test_library) {
            pCompileResult->GetResult(pShaderBlob.GetAddressOf());
            ComPtr<IDxcBlobEncoding> pBlobEncoding;
            pLibrary->CreateBlobWithEncodingFromPinned(
                pShaderBlob->GetBufferPointer(),
                (uint32_t)pShaderBlob->GetBufferSize(), CP_UTF8,
                pBlobEncoding.GetAddressOf());
            pContainer->Load(pBlobEncoding.Get());
            UINT32 shader_idx;
            pContainer->FindFirstPartKind(DXIL_FOURCC('D', 'X', 'I', 'L'),
                                          &shader_idx);
            pContainer->GetPartReflection(
                shader_idx, IID_PPV_ARGS(pShaderReflection.GetAddressOf()));
        }
        else {
            pCompileResult->GetOutput(DXC_OUT_REFLECTION,
                                      IID_PPV_ARGS(pReflectionData.GetAddressOf()),
                                      nullptr);
            shaderBuffer.Ptr      = pReflectionData->GetBufferPointer();
            shaderBuffer.Size     = pReflectionData->GetBufferSize();
            shaderBuffer.Encoding = 0;
        }
    }
    else {
        auto path = rawDxilPath;
        // both reflection and dxil would work
        // path += "\\..\\..\\..\\shaders\\hjr.ref";
        // path += "\\..\\..\\..\\shaders\\HJ.dxil";

        cout << "Getting d3d12 reflection data from ref file: " << path << endl;

        std::ifstream file(path, std::ios::binary | std::ios::ate);
        cout << "Create ifstream" << endl;
        std::streamsize size = file.tellg();
        cout << "Getting file size" << size << endl;
        file.seekg(0, std::ios::beg);
        cout << "file.seekg" << endl;
        raw_buffer.resize(size);
        if (file.read(raw_buffer.data(), size)) {
            cout << "Yes I found dlls!!!" << path << endl;
            // raw buffer could contain dxil or just reflection data
            shaderBuffer.Ptr      = raw_buffer.data();
            shaderBuffer.Size     = size;
            shaderBuffer.Encoding = 0;
        }
        else {
            cout << "FAILED: No I cannot find dlls!!!" << endl;
            return 0;
        }
    }

    HRESULT hr = S_OK;

    if (!test_library) {
        hr = pUtils->CreateReflection(&shaderBuffer,
                                      IID_PPV_ARGS(pShaderReflection.GetAddressOf()));
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
            // https://learn.microsoft.com/en-us/windows/win32/api/d3d12shader/ns-d3d12shader-d3d12_shader_input_bind_desc
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
