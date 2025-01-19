import torch
import time

def test_pytorch_performance(device):
    # 设置张量的大小
    size = (10000, 10000)

    # 在指定设备上创建随机张量
    x = torch.randn(size, device=device)
    y = torch.randn(size, device=device)

    # 测量加法运算时间
    start_time = time.time()
    z = x + y
    torch.cuda.synchronize()  # 如果在 GPU 上，确保所有计算完成
    end_time = time.time()
    print(f"Time taken for addition on {device}: {end_time - start_time:.4f} seconds")

    # 测量矩阵乘法时间
    start_time = time.time()
    z = torch.mm(x, y)
    torch.cuda.synchronize()  # 如果在 GPU 上，确保所有计算完成
    end_time = time.time()
    print(f"Time taken for matrix multiplication on {device}: {end_time - start_time:.4f} seconds")

# 测试在 CPU 上
print("Testing on CPU...")
test_pytorch_performance(device='cpu')

# 测试在 GPU 上
if torch.cuda.is_available():
    print("Testing on GPU...")
    test_pytorch_performance(device='cuda')
else:
    print("GPU is not available.")