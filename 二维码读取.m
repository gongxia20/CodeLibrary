
#import "QrcodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QrcodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
- (IBAction)closeBtnClick:(id)sender;

/**
 *  会话
 */
@property (nonatomic, strong) AVCaptureSession *session;
/**
 *  预览界面
 */
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) CADisplayLink *link;
@end

@implementation QrcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建定时器
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.link = link;
    
    /*
     什么是输入设备: 摄像头, 话筒
     */
    // 1.获取输入设备
#warning 注意, 获取输入设备一定要通过default方法获取, 不能直接alloc init, 否则报错
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 2.根据输入设备创建输入对象
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:inputDevice error:NULL];
    
    // 3.创建输出对象
    AVCaptureMetadataOutput *output =[[AVCaptureMetadataOutput alloc] init];
    // 4.设置输出对象的代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 5.创建会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    // 6.将输入和输出添加到会话中
#warning 由于输入和输入不能重复添加, 所以添加之前需要判断是否可以添加
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
#warning 注意: 设置数据类型一定要在输入对象添加到会话以后再设置, 否则会报错
    // 7.设置输出的数据类型(告诉输出对象能够解析什么类型的数据)
//    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    [output setMetadataObjectTypes:
     
     @[AVMetadataObjectTypeUPCECode,
       
       AVMetadataObjectTypeCode39Code,
       
       AVMetadataObjectTypeCode39Mod43Code,
       
       AVMetadataObjectTypeEAN13Code,
       
       AVMetadataObjectTypeEAN8Code,
       
       AVMetadataObjectTypeCode93Code,
       
       AVMetadataObjectTypeCode128Code,
       
       AVMetadataObjectTypePDF417Code,
       
       AVMetadataObjectTypeAztecCode,
       
       AVMetadataObjectTypeInterleaved2of5Code,
       
       AVMetadataObjectTypeITF14Code,
       
       AVMetadataObjectTypeDataMatrixCode]];
    
    
    // 8.设置预览界面
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
    // 8.开始采集数据
#warning 扫描二维码是一个很持久的操作, 也就是说需要花费很长的时间
    [session startRunning];
}

#pragma mark -  AVCaptureMetadataOutputObjectsDelegate
// 只要解析到了数据就会调用
// 注意: 该方法的调用频率非常高
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    DDActionLog;
    // 1.判断是否解析到了数据
    if (metadataObjects.count > 0 ) {
        // 2.停止扫描
        [self.session stopRunning];
        
        // 3.移除预览界面
        [self.previewLayer removeFromSuperlayer];
        
        // 4.取出数据
//        DDLogDebug(@"%@", [metadataObjects lastObject]);
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects lastObject];
        DDLogDebug(@"%@", obj.stringValue);
        
        // 5.停止动画
        [self.link invalidate];
        self.link = nil;
        
        // 6.显示数据
        UILabel *labbel = [[UILabel alloc] initWithFrame:self.view.bounds];
        labbel.numberOfLines = 0;
        labbel.text = obj.stringValue;
        [self.view addSubview:labbel];
    }
}

@end
