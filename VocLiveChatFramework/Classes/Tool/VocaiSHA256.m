//
//  VocaiSHA256.m
//  Pods
//
//  Created by Boyuan Gao on 2025/6/6.
//
#import "VocaiSHA256.h"

@implementation VocaiSHA256

// SHA-256常量
static const uint32_t k[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

// 右旋转函数
static uint32_t rightrotate(uint32_t x, uint32_t c) {
    return (x >> c) | (x << (32 - c));
}

// 计算SHA256哈希
+ (NSData *)computeSHA256:(const uint8_t *)data length:(size_t)length {
    // 初始化哈希值
    uint32_t h[8] = {
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    };
    
    // 消息长度（以比特为单位）
    uint64_t bitLength = length * 8;
    
    // 计算填充后的消息长度
    size_t blockCount = ((length + 8) / 64 + 1) * 64;
    uint8_t *message = (uint8_t *)malloc(blockCount);
    if (!message) return nil;
    
    // 复制原始数据
    memcpy(message, data, length);
    
    // 添加填充位
    message[length] = 0x80; // 添加1比特后跟0比特
    
    // 填充0直到消息长度 ≡ 448 (mod 512)
    for (size_t i = length + 1; i < blockCount - 8; i++) {
        message[i] = 0;
    }
    
    // 添加原始消息长度（以比特为单位，64位大端序）
    for (int i = 7; i >= 0; i--) {
        message[blockCount - 8 + i] = (uint8_t)(bitLength >> (i * 8));
    }
    
    // 处理每个64字节块
    for (size_t i = 0; i < blockCount; i += 64) {
        uint32_t w[64];
        
        // 将块分解为16个32位大端序字
        for (int j = 0; j < 16; j++) {
            w[j] = (message[i + j*4] << 24) |
                   (message[i + j*4 + 1] << 16) |
                   (message[i + j*4 + 2] << 8) |
                   message[i + j*4 + 3];
        }
        
        // 扩展为64个字
        for (int j = 16; j < 64; j++) {
            uint32_t s0 = rightrotate(w[j-15], 7) ^ rightrotate(w[j-15], 18) ^ (w[j-15] >> 3);
            uint32_t s1 = rightrotate(w[j-2], 17) ^ rightrotate(w[j-2], 19) ^ (w[j-2] >> 10);
            w[j] = w[j-16] + s0 + w[j-7] + s1;
        }
        
        // 初始化工作变量
        uint32_t a = h[0];
        uint32_t b = h[1];
        uint32_t c = h[2];
        uint32_t d = h[3];
        uint32_t e = h[4];
        uint32_t f = h[5];
        uint32_t g = h[6];
        uint32_t hh = h[7];
        
        // 主循环
        for (int j = 0; j < 64; j++) {
            uint32_t S1 = rightrotate(e, 6) ^ rightrotate(e, 11) ^ rightrotate(e, 25);
            uint32_t ch = (e & f) ^ ((~e) & g);
            uint32_t temp1 = hh + S1 + ch + k[j] + w[j];
            uint32_t S0 = rightrotate(a, 2) ^ rightrotate(a, 13) ^ rightrotate(a, 22);
            uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
            uint32_t temp2 = S0 + maj;
            
            hh = g;
            g = f;
            f = e;
            e = d + temp1;
            d = c;
            c = b;
            b = a;
            a = temp1 + temp2;
        }
        
        // 添加到当前哈希值
        h[0] += a;
        h[1] += b;
        h[2] += c;
        h[3] += d;
        h[4] += e;
        h[5] += f;
        h[6] += g;
        h[7] += hh;
    }
    
    // 生成最终哈希数据
    uint8_t hash[32];
    for (int i = 0; i < 8; i++) {
        hash[i*4] = (uint8_t)(h[i] >> 24);
        hash[i*4 + 1] = (uint8_t)(h[i] >> 16);
        hash[i*4 + 2] = (uint8_t)(h[i] >> 8);
        hash[i*4 + 3] = (uint8_t)h[i];
    }
    
    // 创建NSData对象
    NSData *result = [NSData dataWithBytes:hash length:32];
    free(message);
    
    return result;
}

// 转换为十六进制字符串
+ (NSString *)hexStringFromData:(NSData *)data {
    const uint8_t *bytes = (const uint8_t *)data.bytes;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:data.length * 2];
    
    for (NSInteger i = 0; i < data.length; i++) {
        [hexString appendFormat:@"%02x", bytes[i]];
    }
    
    return [hexString copy];
}

// 计算字符串的SHA256哈希值
+ (NSString *)hashString:(NSString *)string {
    if (!string) return nil;
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *hashData = [self computeSHA256:data.bytes length:data.length];
    return [self hexStringFromData:hashData];
}

// 计算NSData的SHA256哈希值
+ (NSString *)hashData:(NSData *)data {
    if (!data) return nil;
    
    NSData *hashData = [self computeSHA256:data.bytes length:data.length];
    return [self hexStringFromData:hashData];
}

@end
