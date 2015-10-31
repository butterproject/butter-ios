//
//  ButterTorrentStreamer.h
//  Butter
//
//  Created by Danylo Kostyshyn on 2/23/15.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    float bufferingProgress;
    float totalProgreess;
    int downloadSpeed;
    int upoadSpeed;
    int seeds;
    int peers;
} ButterTorrentStatus;

typedef void (^ButterTorrentStreamerProgress)(ButterTorrentStatus status);
typedef void (^ButterTorrentStreamerReadyToPlay)(NSURL *videoFileURL);
typedef void (^ButterTorrentStreamerFailure)(NSError *error);

@interface ButterTorrentStreamer : NSObject

+ (instancetype)sharedStreamer;

- (void)startStreamingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink
                                   runtime:(int)runtime
                                  progress:(ButterTorrentStreamerProgress)progreess
                               readyToPlay:(ButterTorrentStreamerReadyToPlay)readyToPlay
                                   failure:(ButterTorrentStreamerFailure)failure;

- (void)cancelStreaming;

@end
