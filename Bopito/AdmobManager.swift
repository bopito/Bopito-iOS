//
//  AdmobManager.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/10/24.
//

import Foundation
import GoogleMobileAds

class AdmobManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    
    private var rewardedAd: GADRewardedAd?
    
    func loadAd(userID: String) async {
        do {
            var adUnitID = "ca-app-pub-5387496707984386/1714082165"
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                adUnitID = "ca-app-pub-3940256099942544/1712485313"
            }
            let options = GADServerSideVerificationOptions()
            options.userIdentifier = userID
            
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: adUnitID,
                request: GADRequest()
            )
            // Set server-side verification options on the rewarded ad
            rewardedAd?.serverSideVerificationOptions = options
                    
            // [START set_the_delegate]
            rewardedAd?.fullScreenContentDelegate = self
            // [END set_the_delegate]
        } catch {
            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
        }
    }
    // [END load_ad]
    
    // [START show_ad]
    func showAd() {
        guard let rewardedAd = rewardedAd else {
            return print("Ad wasn't ready.")
        }
        
        rewardedAd.present(fromRootViewController: nil) {
            let reward = rewardedAd.adReward
            print("Reward amount: \(reward.amount.intValue)")
        }
    }
    // [END show_ad]
    
    
    
    // MARK: - GADFullScreenContentDelegate methods
    
    // [START ad_events]
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func ad(
        _ ad: GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("\(#function) called")
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        // Clear the rewarded ad.
        rewardedAd = nil
    }
    // [END ad_events]
}
