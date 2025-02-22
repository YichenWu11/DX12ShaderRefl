// ShaderReflection.cpp : Defines the entry point for the application.
//

#include <wrl.h>
#include "d3dcompiler.h"
#include "FxcShaderReflection.h"
#include <fstream>
#include <filesystem>
#include <vector>
#include <cassert>
#include "CommonShader.h"

using namespace std;
using Microsoft::WRL::ComPtr;

int main()
{
	ComPtr<ID3DBlob> pBlob;
	ComPtr<ID3DBlob> pErrorBlob;
	uint32_t shader_size = (uint32_t)shader_source.size();
	auto hr = D3DCompile2(shader_source.c_str(), shader_size, nullptr, nullptr, nullptr, "main", "ps_5_1", 0, 0, 0, nullptr, 0, pBlob.GetAddressOf(), pErrorBlob.GetAddressOf());

	ComPtr<ID3D12ShaderReflection> pShaderReflection;
	if (hr != S_OK)
	{
		if (pErrorBlob)
		{
			char* c_error_messages = static_cast<char*>(pErrorBlob->GetBufferPointer());
			std::string error_messages = std::string(c_error_messages);
			cout << error_messages << endl;
		}
		cout << "Compiling Shader failed!" << endl;
		return 0;
	}
	else
	{
		hr = D3DReflect(pBlob->GetBufferPointer(), pBlob->GetBufferSize(), IID_PPV_ARGS(pShaderReflection.GetAddressOf()));
	}

	if (hr == S_OK)
	{
		D3D12_SHADER_DESC desc;
		pShaderReflection->GetDesc(&desc);

		auto const_buffer_count = desc.ConstantBuffers;
		for (uint32_t i = 0; i < const_buffer_count; ++i)
		{
			auto cbuffer = pShaderReflection->GetConstantBufferByIndex(i);
			D3D12_SHADER_BUFFER_DESC buffer_desc;
			cbuffer->GetDesc(&buffer_desc);
			auto const_buffer = pShaderReflection->GetConstantBufferByName(buffer_desc.Name);
			assert(cbuffer == const_buffer);

			cout << "Constant Buffer: " << buffer_desc.Name << " with size: " << buffer_desc.Size << " with Var count: " << buffer_desc.Variables << endl;
			auto var_count = buffer_desc.Variables;
			for (uint32_t j = 0; j < var_count; ++j)
			{
				auto var = const_buffer->GetVariableByIndex(j);
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
		for (uint32_t i = 0; i < binding_count; ++i)
		{
			D3D12_SHADER_INPUT_BIND_DESC desc;
			auto binding = pShaderReflection->GetResourceBindingDesc(i, &desc);
			cout << "Name: " << desc.Name << endl;
			cout << "	Type:		" << desc.Type << endl;
			cout << "	Dimension:	" << desc.Dimension << endl;
			cout << "	BindCount:	" << desc.BindCount << endl;
			cout << "	BindPoint:	" << desc.BindPoint << endl;
			cout << "	Space:		" << desc.Space << endl;
			cout << "	NumSamples: " << desc.NumSamples << endl;
		}
	}
	else
	{
		cout << "FAILED: Cannot get reflection data!!!" << endl;
	}
	
	
	return 0;
}
