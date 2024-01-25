//
//  AVAssetExtension.swift
//  Soundify
//
//  Created by 서정덕 on 2023/08/06.
//

import AVFoundation

extension AVAsset {

    // AVAsset에서 오디오 트랙을 분리하고, .m4a 오디오 파일로 저장하는 메서드
    func saveAudioFileToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        print("\(type(of: self)) - \(#function)")

        do {
            // 오디오 트랙을 분리하여 새로운 AVAsset로 변환
            let audioAsset = try self.audioAsset()
            // 분리된 오디오 트랙을 .m4a 오디오 파일로 저장
            audioAsset.writeToURL(url, completion: completion)
        } catch (let error as NSError){
            completion(false, error)
        }
    }

    // AVAsset에서 오디오 트랙을 분리하는 메서드
    func audioAsset() throws -> AVAsset {
        print("\(type(of: self)) - \(#function)")

        // 오디오 트랙을 저장할 AVMutableComposition 객체 생성
        let composition = AVMutableComposition()
        // AVAsset에서 오디오 트랙 추출
        let audioTracks = tracks(withMediaType: .audio)

        // 추출한 오디오 트랙을 AVMutableComposition에 추가
        for track in audioTracks {

            let compositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            compositionTrack?.preferredTransform = track.preferredTransform
        }
        return composition // 오디오 트랙이 저장된 AVMutableComposition 객체 반환
    }
    
    // AVAsset에서 .m4a 오디오 파일로 변환하여 저장하는 메서드
    func writeToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        print("\(type(of: self)) - \(#function)")

        // AVAssetExportSession을 생성하여 .m4a 오디오 파일로 변환
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A) else {
            completion(false, nil)
            return
        }
        
        // TODO: 다른 파일도 되나 확인
        // 번환할 파일의 확장자, url 설정
        exportSession.outputFileType = .m4a
        exportSession.outputURL = url

        // .m4a 오디오 파일로 변환을 비동기적으로 수행
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(true, nil) // 변환 성공
            default:
                completion(false, nil) // 변환 실패
            }
        }
    }
}
