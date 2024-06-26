//
//  AudioManager.swift
//  Soundify
//
//  Created by 서정덕 on 2023/08/06.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private init() { }
    
    var audioPlayer: AVAudioPlayer?
    
    func playMusicByFileName(named fileName: String, withExtension fileExtension: String) {
        print("\(type(of: self)) - \(#function)")

        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("오디오 파일을 찾을 수 없습니다.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("오디오 재생 중 오류가 발생했습니다: \(error.localizedDescription)")
        }
    }
    
    func playMusicByURL(url: URL) {
        print("\(type(of: self)) - \(#function)")

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("오디오 재생 중 오류가 발생했습니다: \(error.localizedDescription)")
        }
    }
    
    func registerAudioByURL(url: URL) {
        print("\(type(of: self)) - \(#function)")

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            print("오디오 등록 성공")
        } catch {
            print("오디오 등록 중 오류가 발생했습니다: \(error.localizedDescription)")
        }
    }
    
    func playMusic() {
        print("\(type(of: self)) - \(#function)")

        if self.audioPlayer != nil {
            self.audioPlayer!.play()
        }
        else {
            print("audioPlayer = nil")
        }
    }
    
    func pauseMusic() {
        print("\(type(of: self)) - \(#function)")

        if self.audioPlayer != nil {
            self.audioPlayer!.pause()
        }
        else {
            print("audioPlayer = nil")
        }
    }
    
    func stopMusic() {
        print("\(type(of: self)) - \(#function)")

        if self.audioPlayer != nil {
            self.audioPlayer!.stop()
        }
        else {
            print("audioPlayer = nil")
        }
    }
}

