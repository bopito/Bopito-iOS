//
//  AdmobManager.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/10/24.
//

import Foundation
import GoogleMobileAds

class AdmobManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
  @Published var coins = 0
  private var rewardedAd: GADRewardedAd?

  func loadAd() async {
    do {
      rewardedAd = try await GADRewardedAd.load(
        withAdUnitID: "ca-app-pub-5387496707984386/1714082165", request: GADRequest())
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
      print("Reward amount: \(reward.amount)")
      self.addCoins(reward.amount.intValue)
        print(self.coins)
    }
  }
  // [END show_ad]

  func addCoins(_ amount: Int) {
    coins += amount
  }

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
