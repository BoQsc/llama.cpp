# Spark DSpark: Windows CUDA build + OpenAI-compatible API

This directory and [workflow](../.github/workflows/build-spark-dspark.yml) add an easy-to-download Windows build to the **BoQsc/llama.cpp** fork. The existing llama.cpp source is preserved.

## Automatic GitHub Release

- **Actions workflow:** [Build Spark DSpark - Windows CUDA 12.4](https://github.com/BoQsc/llama.cpp/actions/workflows/build-spark-dspark.yml)
- **Build:** Windows x64, CUDA 12.4, NVIDIA SM 89 (RTX 4090), `llama-server.exe` with `draft-dspark` support.
- **Triggers:** manual **Run workflow**, or pushes to `master` changing this workflow, DSpark scripts, or core llama.cpp source.
- **Result:** a `spark-dspark-win-x64-cuda12.4-sm89.zip` in [Releases](https://github.com/BoQsc/llama.cpp/releases), plus a temporary Actions artifact.
- **Requirements:** GitHub Actions must be enabled in your fork. A build might take substantial runner time.

The workflow uses the source code from the exact fork commit recorded in `SOURCE-REVISION.txt` and checks that the compiled `llama-server.exe --help` advertises `draft-dspark`. GitHub-hosted Windows runners have no NVIDIA GPU, so actual model inference requires local testing.

## Run on Windows

1. Download the latest `spark-dspark-win-x64-cuda12.4-sm89.zip` from **Releases** and extract it.
2. Download a target model GGUF from [XHToken/Spark-X2.6-4B-GGUF](https://huggingface.co/XHToken/Spark-X2.6-4B-GGUF) and a **matching** DSpark draft GGUF from [XHToken/Spark-X2.6-4B-DSpark-GGUF](https://huggingface.co/XHToken/Spark-X2.6-4B-DSpark-GGUF).
3. Put them in the extracted `models` folder as `Spark-target.gguf` and `Spark-draft.gguf`.
4. Double-click `start-dspark.cmd`; then double-click `test-api.cmd` in another window to send a sample chat request.

**Local API base URL:** `http://127.0.0.1:8080/v1`

**Model ID:** `spark-dspark`

**Chat endpoint:** `POST http://127.0.0.1:8080/v1/chat/completions`

The default server binds to `127.0.0.1`, not the public internet, and does not require an API key locally. To change settings, use PowerShell from the extracted directory:

```powershell
.\start-dspark.ps1 -TargetModel 'D:\Models\target.gguf' -DraftModel 'D:\Models\draft.gguf' -Context 16384 -Port 8081
```

Other launcher arguments: `-Threads 8`, `-ModelAlias`, `-ApiKey`, `-HostAddress`, and `-ExtraArgs @('--verbose')`. Do not expose the server to a network without authentication and appropriate network protections.

The script uses DSpark speculative decoding:

```text
--spec-type draft-dspark --spec-draft-sampling greedy
--spec-draft-n-max 7 --spec-draft-p-min 0
-ngl 999 -ngld 999 -ctk f16 -ctv f16 -ctkd f16 -ctvd f16
-fa on -c 8192 -np 1 --jinja
```

**Notes:** The ZIP does not include GGUF model weights, an NVIDIA driver, or the Microsoft Visual C++ Redistributable. Your GPU driver must support CUDA 12.4. The build embeds SM 89 kernels for the RTX 4090; users of other GPU architectures should adapt `CMAKE_CUDA_ARCHITECTURES` before building.

## Sources and licensing

- [Official Spark-X2.6 DSpark model card](https://huggingface.co/XHToken/Spark-X2.6-4B-DSpark-GGUF)
- [XHToken/llama.cpp](https://github.com/XHToken/llama.cpp)
- [llama.cpp speculative decoding documentation](https://github.com/XHToken/llama.cpp/blob/master/docs/speculative.md)
- [llama.cpp build documentation](https://github.com/XHToken/llama.cpp/blob/master/docs/build.md)

The binary retains the upstream llama.cpp license. Spark model weights carry their own license. Bundled NVIDIA CUDA runtime DLLs are subject to NVIDIA's redistribution terms.
