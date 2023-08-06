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
    
    private var audioPlayer: AVAudioPlayer?
    
    func playMusicByFileName(named fileName: String, withExtension fileExtension: String) {
        print("AudioManager - playMusicByFileName")

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
        print("AudioManager - playMusicByURL")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("오디오 재생 중 오류가 발생했습니다: \(error.localizedDescription)")
        }
    }
    
    func pauseMusic() {
        self.audioPlayer?.pause()
    }
    
    func stopMusic() {
        self.audioPlayer?.stop()
    }
}

