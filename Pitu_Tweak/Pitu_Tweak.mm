#import "Pitu_Tweak.h"
#import "YYHelper.h"
#import "YYHooK.h"
#import "AFNetworking.h"
#import "THCircularProgressView.h"
#import "RequestPostUploadHelper.h"
#import <pthread.h>



int iNum=0;
NSMutableArray *fileList = [[NSMutableArray alloc] init];

void SavePostHairMaskPic(NSString *fileName,NSString *fileDir,NSUInteger  iNum, void(^completion)(void))
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //   NSString *path =[NSString stringWithFormat:@"%@/Documents/Group6_Src/%@",NSHomeDirectory(),fileName];
    NSString *path =[NSString stringWithFormat:@"%@%@",fileDir,fileName];
    
    // [YYHelper YYLog:path,nil];
    UIImage  *myImage=[UIImage imageWithContentsOfFile:path];
    
    
    [myImage resizeImageWithMaxSize:CGSizeMake( 321,321)];
    NSData *imageData = UIImageJPEGRepresentation(myImage,  1.0);;
    NSString *str=[imageData base64EncodedStringWithOptions:0];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:@"1" forKeyedSubscript:@"type"];
    [dic setObject:str  forKeyedSubscript:@"photo_data"];
    
    NSMutableData *data2=[NSMutableData dataWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *str2=[NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c",0x72, 0x44,0x7A, 0x6F,0x69,0x65,0x35, 0x65,0x33, 0x6F, 0x6E,0x67, 0x66, 0x7A,0x31,0x6C];
    [data2 appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *strMD5Key=[data2 MD5String];
    [dic setObject:strMD5Key forKeyedSubscript:@"key"];
    // [YYHelper YYLog:strMD5Key,nil];
    // 设置请求格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:@"http://tu.qq.com/cgi/doHairMask.php" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic2 = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSString *result = dic2[@"photo_data"];
        
        NSData *photoData=[[NSData alloc] initWithBase64EncodedString: result options:0];
        UIImage* imageToSave=[UIImage  imageWithData:photoData];
        NSString *DesDirPath = [NSString stringWithFormat:@"%@/Documents/DesPic/%@", NSHomeDirectory(),fileName];
        [UIImagePNGRepresentation(imageToSave) writeToFile:DesDirPath atomically:YES];
        [photoData release];
        if (completion) {
            completion();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion();
        }
        [YYHelper YYLog:[NSString stringWithFormat:@"POST失败于第%d张图片",iNum],nil];
    }];
    
    
}



id (*Old_init)(id self,SEL _cmd);
id New_init(id self,SEL _cmd)
{

   
    return Old_init(self,_cmd);
}

id (*Old_hairMask)(id self,SEL _cmd);
id New_hairMask(id  self,SEL _cmd)
{

    return  Old_hairMask(self,_cmd);
   
}
void (*Old_getHairmaskUploadImage)(id self ,SEL _cmd ,id arg1, int arg2);
void New_getHairmaskUploadImage(id self ,SEL _cmd ,id arg1, int arg2)
{
    

    
    return Old_getHairmaskUploadImage(self,_cmd,arg1,arg2);
}
void (*Old_didSelectedAtIndex)(id self,SEL _cmd,int index, id arg2);

void LoopSavePostHairMaskPic(NSMutableArray *files,NSString *fileDir, void(^completion)(void))
{
    if (files.count == 0) {
        if (completion) {
            completion();
        }
    } else {
        SavePostHairMaskPic([files lastObject],fileDir, files.count - 1, ^(){
            [files removeLastObject];
            LoopSavePostHairMaskPic(files,fileDir, completion);
        });
    }
}


id  createDictionary(UIImage *tempImage)
{
    [tempImage resizeImageWithMaxSize:CGSizeMake( 321,321)];
    NSData *imageData = UIImageJPEGRepresentation(tempImage,  1.0);;
    NSString *str=[imageData base64EncodedStringWithOptions:0];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:@"1" forKeyedSubscript:@"type"];
    [dic setObject:str  forKeyedSubscript:@"photo_data"];
    
    NSMutableData *data2=[NSMutableData dataWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *str2=[NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c",0x72, 0x44,0x7A, 0x6F,0x69,0x65,0x35, 0x65,0x33, 0x6F, 0x6E,0x67, 0x66, 0x7A,0x31,0x6C];
    [data2 appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *strMD5Key=[data2 MD5String];
    [dic setObject:strMD5Key forKeyedSubscript:@"key"];
    
    return dic;
}


//同步POST
void * PostPic_sync(void *){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    
    
    for (int i=0; i<fileList.count; i++)
    {
        
        NSString *tempFileName=[fileList objectAtIndex:i];
        NSString *path =[documentDir stringByAppendingPathComponent: tempFileName];
        UIImage  *myImage=[UIImage imageWithContentsOfFile:path];
        
        //设置Dictionary
        NSMutableDictionary  *dic=createDictionary(myImage);
        
        //Post
        NSData *result=[RequestPostUploadHelper postRequestWithURL:@"http://tu.qq.com/cgi/doHairMask.php" postParems:dic picFilePath:path picFileName:tempFileName];
        
        //获取返回结果
        NSDictionary *dic2 = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        NSString *resultData = dic2[@"photo_data"];
        NSData *photoData=[[NSData alloc] initWithBase64EncodedString: resultData options:0];
        UIImage* imageToSave=[UIImage  imageWithData:photoData];
        //保存结果
        NSString *DesDirPath = [NSString stringWithFormat:@"%@/Documents/DesPic/%@", NSHomeDirectory(),tempFileName];
        [UIImagePNGRepresentation(imageToSave) writeToFile:DesDirPath atomically:YES];
        [photoData release];
    }
    UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertview show];
    [alertview release];
}

//异步POST
void * PostPic_async0(void *){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src0/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src0" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
    
}
void * PostPic_async1(void *)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src1/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src1" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
}

void * PostPic_async2(void *)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src2/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src2" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
}
void * PostPic_async3(void *)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src3/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src3" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
}
void * PostPic_async4(void *)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src4/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src4" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
}
void * PostPic_async5(void *)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src5/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src5" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
}
void * PostPic_async6(void *)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src6/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src6" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
}
void * PostPic_async7(void *)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src7/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src7" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
}
void * PostPic_async8(void *)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src8/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src8" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
}
void * PostPic_async9(void *)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* documentDir =[NSString stringWithFormat:@"%@/Documents/SrcPic/Group_Src9/",NSHomeDirectory()];
    NSError *error = nil;
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [[fileManager contentsOfDirectoryAtPath:documentDir error:&error] mutableCopy];
    
    LoopSavePostHairMaskPic(fileList,documentDir, ^(){
        UIAlertView* alertview=[[UIAlertView alloc]initWithTitle:@"处理" message:@"处理完成Src9" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
        
    });
}
void New_didSelectedAtIndex(id  self,SEL _cmd,int index, id arg2)
{



    //第一种创建线程的方法
      pthread_t thread,thread0,thread1,thread2,thread3,thread4,thread5,thread6,thread7,thread8,thread9;
     //pthread_create(&thread, NULL, PostPic_sync, NULL);
    
    pthread_create(&thread0, NULL, PostPic_async0, NULL);
    pthread_create(&thread1, NULL, PostPic_async1, NULL);
    pthread_create(&thread2, NULL, PostPic_async2, NULL);
    pthread_create(&thread3, NULL, PostPic_async3, NULL);
    pthread_create(&thread4, NULL, PostPic_async4, NULL);
    pthread_create(&thread5, NULL, PostPic_async5, NULL);
    pthread_create(&thread6, NULL, PostPic_async6, NULL);
    pthread_create(&thread7, NULL, PostPic_async7, NULL);
    pthread_create(&thread8, NULL, PostPic_async8, NULL);
    pthread_create(&thread9, NULL, PostPic_async9, NULL);
    
    
    //第二种创建线程的方法
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_async(queue,PostPic);

    return Old_didSelectedAtIndex(self,_cmd,index,arg2);;
}



MSInitialize
{

    
    Class class__CosmeticViewController = objc_getClass("CosmeticViewController");
    MSHookMessageEx(class__CosmeticViewController, @selector(didSelectedAtIndex:ofBar:), (IMP)&New_didSelectedAtIndex, (IMP*)&Old_didSelectedAtIndex);
}