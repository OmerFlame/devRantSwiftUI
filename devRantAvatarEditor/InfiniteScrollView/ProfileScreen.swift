//
//  ProfileScreen.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 11/26/20.
//

import UIKit
import Combine
import SwiftUI


class ProfileScreen: UITableViewController {
    var profileData: Profile
    var userID: Int
    @ObservedObject var profile = profileViewData()
    var supplementalImages = [UIImage?]()
    var image: UIImage?
    
    var originalBlurRect: CGRect!
    var originalTitleRect: CGRect!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var headerImageContainer: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var largeHeaderTitle: UIStackView!
    @IBOutlet weak var smallHeaderTitle: UIStackView!
    
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var imageContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    
    init?(userID: Int, profileData: Profile, image: UIImage?, coder: NSCoder) {
        self.userID = userID
        self.profileData = profileData
        self.image = image
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(userID:profileData:image:coder:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal static func initialize(userID: Int, profileData: Profile, image: UIImage?) -> ProfileScreen {
        let vc = UIStoryboard(name: "ProfileScreen", bundle: nil).instantiateViewController(identifier: "ProfileScreen", creator: { coder in
            ProfileScreen(userID: userID, profileData: profileData, image: image, coder: coder)
        })
        //vc.userID = userID
        //vc.profileData = profileData
        //vc.image = image
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerContainerView.backgroundColor = UIColor(hex: profileData.avatar.b)!
        headerImageContainer.backgroundColor = UIColor(hex: profileData.avatar.b)!
        headerImageView.backgroundColor = UIColor(hex: profileData.avatar.b)!
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 382, height: 382), false, CGFloat(image!.size.height / 382))
        image!.draw(in: CGRect(origin: .zero, size: CGSize(width: 382, height: 382)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        headerImageView.image = newImage
        
        originalBlurRect = blurView.frame
        originalTitleRect = largeHeaderTitle.frame
        
        scrollViewDidScroll(tableView)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        
        let headerGeometry = self.geometry(view: headerView, scrollView: scrollView)
        let titleGeometry = self.geometry(view: largeHeaderTitle, scrollView: scrollView)
        
        headerContainerView.alpha = CGFloat(sqrt(headerGeometry.largeTitleWeight))
        headerImageContainer.alpha = CGFloat(sqrt(headerGeometry.largeTitleWeight))
        
        let largeTitleOpacity = (max(titleGeometry.largeTitleWeight, 0.5) - 0.5) * 2
        let tinyTitleOpacity = 1 - min(titleGeometry.largeTitleWeight, 0.5) * 2
        
        largeHeaderTitle.alpha = CGFloat(sqrt(largeTitleOpacity))
        
        smallHeaderTitle.alpha = CGFloat(sqrt(tinyTitleOpacity))
        
        if let vfxSubview = blurView.subviews.first(where: {
            String(describing: type(of: $0)) == "_UIVisualEffectSubview"
        }) {
            vfxSubview.backgroundColor = UIColor.systemBackground.withAlphaComponent(0)
        }
        
        if let vfxBackdrop = blurView.subviews.first(where: {
            String(describing: type(of: $0)) == "_UIVisualEffectBackdropView"
        }) {
            vfxBackdrop.alpha = CGFloat(1 - sqrt(titleGeometry.largeTitleWeight))
        }
        
        var blurFrame = blurView.frame
        var titleFrame = largeHeaderTitle.frame
        
        blurFrame.origin.y = max(originalBlurRect.minY, originalBlurRect.minY + titleGeometry.blurOffset)
        titleFrame.origin.y = originalTitleRect.minY + 396
        
        blurView.frame = blurFrame
        largeHeaderTitle.frame = titleFrame
        
        containerViewHeight.constant = scrollView.contentInset.top
        headerContainerView.clipsToBounds = offsetY <= 0
        imageContainerBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
        imageContainerHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
        headerImageContainer.clipsToBounds = offsetY <= 0
        
        imageViewBottom.constant = (offsetY >= 0 ? 0 : -offsetY / 2) + 50
        imageViewTop.constant = (offsetY >= 0 ? 0 : -offsetY / 2) - 50
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10000
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostingCell", for: indexPath)

        // Configure the cell...
        let hostingController = UIHostingController<Text>(rootView: Text("\(indexPath.row)"))
        
        let requiresControllerMove = hostingController.parent != self
        if requiresControllerMove {
            self.addChild(hostingController)
        }
        
        if !cell.contentView.subviews.contains(hostingController.view) {
            cell.contentView.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            hostingController.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            hostingController.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            hostingController.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        }
        
        cell.layoutIfNeeded()
        
        cell.contentView.frame.size.height = hostingController.view.intrinsicContentSize.height
        
        cell.invalidateIntrinsicContentSize()
        cell.contentView.invalidateIntrinsicContentSize()
        
        hostingController.view.layoutIfNeeded()
        
        if requiresControllerMove {
            hostingController.didMove(toParent: self)
        }
        
        //height = self.contentView.frame.size.height
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileScreen {
    struct HeaderGeometry {
        let width: CGFloat
        let headerHeight: CGFloat
        let elementsHeight: CGFloat
        let headerOffset: CGFloat
        let blurOffset: CGFloat
        let elementsOffset: CGFloat
        let largeTitleWeight: Double
    }
    
    func geometry(view: UIView, scrollView: UIScrollView) -> HeaderGeometry {
        let safeArea = scrollView.safeAreaInsets
        
        let minY = -(scrollView.contentOffset.y + scrollView.safeAreaInsets.top)
        
        let hasScrolledUp = minY > 0
        
        let hasScrolledToMinHeight = -minY >= 450 - 47 - safeArea.top

        let headerHeight = hasScrolledUp ?
            headerContainerView.frame.size.height + minY + 32 : headerContainerView.frame.size.height + 32

        let elementsHeight = headerView.frame.size.height + minY

        let headerOffset: CGFloat
        let blurOffset: CGFloat
        let elementsOffset: CGFloat
        let largeTitleWeight: Double

        if hasScrolledUp {
            headerOffset = -minY
            blurOffset = -minY
            elementsOffset = -minY
            largeTitleWeight = 1
        } else if hasScrolledToMinHeight {
            headerOffset = -minY - 450 + 47 + safeArea.top
            blurOffset = -minY - 450 + 47 + safeArea.top - 32
            elementsOffset = headerOffset / 2 - minY / 2
            largeTitleWeight = 0
        } else {
            headerOffset = 0
            blurOffset = 0
            elementsOffset = -minY / 2
            let difference = 450 - 47 - safeArea.top + minY
            largeTitleWeight = difference <= 47 + 1 ? Double(difference / (47 + 1)) : 1
        }
        
        return HeaderGeometry(width: headerView.frame.size.width, headerHeight: headerHeight, elementsHeight: elementsHeight, headerOffset: headerOffset, blurOffset: blurOffset, elementsOffset: elementsOffset, largeTitleWeight: largeTitleWeight)
    }
}

struct ProfileScreenRepresentable: UIViewControllerRepresentable {
    let userID: Int
    @Binding var profileData: Profile?
    @Binding var image: UIImage?
    
    init(userID: Int, profileData: Binding<Profile?>, image: Binding<UIImage?>) {
        self.userID = userID
        self._profileData = profileData
        self._image = image
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let profileScreen = ProfileScreen.initialize(userID: self.userID, profileData: self.profileData!, image: self.image)
        
        return profileScreen
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
