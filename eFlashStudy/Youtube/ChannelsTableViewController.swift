//
//  ChannelsTableViewController.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 6. 20..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChannelsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Section 수를 반환한다.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Section의 cell 수를 반환한다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudyDataStruct.channelsDataArray.count
    }

    // Index에 해당하는 Row를 cell에 확인한다.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath as IndexPath)

        let thumbnailImageView = cell.viewWithTag(10) as? UIImageView
        let channelTitleLabel = cell.viewWithTag(11) as? UILabel
        let channelDescriptionLabel = cell.viewWithTag(12) as? UILabel

        let channelDetails = StudyDataStruct.channelsDataArray[indexPath.row]

        channelTitleLabel!.text = channelDetails["title"]
        channelDescriptionLabel!.text = channelDetails["description"]
        thumbnailImageView!.image = UIImage(data: NSData(contentsOf: NSURL(string: (channelDetails["thumbnail"])!)! as URL)! as Data)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goYoutubeView", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var selectedChannel: String = ""

        if segue.identifier == "goYoutubeView" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let channelDetails = StudyDataStruct.channelsDataArray[indexPath.row]
                selectedChannel = channelDetails["id"]!
            }

            let controller = segue.destination as? YoutubeWebController
            controller!.selectedChannel = selectedChannel
        }
    }

}
