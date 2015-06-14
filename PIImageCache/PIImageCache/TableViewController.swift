import UIKit


class TableViewCell : UITableViewCell {
  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var body: UILabel!
}

class TableViewController : UITableViewController {
  
  let lormpixelCategory =
  [ "abstract", "animals", "business", "cats", "city", "food", "nightlife", "fashion", "people", "nature", "sports", "technics", "transport", "abstract", "animals", "business", "cats", "city", "food", "nightlife", "fashion", "people", "nature", "sports", "technics", "transport" ]
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return lormpixelCategory.count
  }
  
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell: TableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
      let i = indexPath.row
      let url = NSURL(string: "http://lorempixel.com/200/200/" + lormpixelCategory[i] )!
      cell.icon.imageOfURL(url)
      cell.body.text = lormpixelCategory[i]
      return cell
  }
  
}
