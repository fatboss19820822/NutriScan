//
//  AcknowledgementsViewController.swift
//  NutriScan
//
//  Created by GPT-5 Codex on 8/11/2025.
//

import UIKit

/// Displays third-party acknowledgements, licenses, and resource attributions used in the app.
final class AcknowledgementsViewController: UITableViewController {

    private let acknowledgements: [AcknowledgementItem] = AcknowledgementsDataProvider.items

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Acknowledgements"
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemGroupedBackground
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acknowledgements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        let item = acknowledgements[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.secondaryText = item.summary
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = acknowledgements[indexPath.row]
        let detailVC = AcknowledgementDetailViewController(item: item)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Acknowledgement Models

private struct AcknowledgementItem {
    let title: String
    let summary: String
    let detail: String
    let website: URL?
}

private enum AcknowledgementsDataProvider {
    static let items: [AcknowledgementItem] = [
        AcknowledgementItem(
            title: "Firebase iOS SDK",
            summary: "Firebase Authentication, Firestore, analytics utilities. Apache License 2.0.",
            detail: """
Firebase iOS SDK (including FirebaseAuth, FirebaseFirestore, FirebaseCore, GoogleAppMeasurement, GoogleUtilities, GoogleDataTransport, gRPC, abseil-cpp, and related components)

Copyright 2013 The Firebase Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
""",
            website: URL(string: "https://github.com/firebase/firebase-ios-sdk")
        ),
        AcknowledgementItem(
            title: "Google Sign-In iOS SDK",
            summary: "Google Sign-In authentication flows. Apache License 2.0.",
            detail: """
Google Sign-In iOS SDK (including GTMAppAuth, GTMSessionFetcher, AppAuth-iOS)

Copyright 2016 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
""",
            website: URL(string: "https://developers.google.com/identity/sign-in/ios")
        ),
        AcknowledgementItem(
            title: "SwiftProtobuf",
            summary: "Swift Protocol Buffers implementation. Apache License 2.0.",
            detail: """
SwiftProtobuf

Copyright 2014 Apple Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
""",
            website: URL(string: "https://github.com/apple/swift-protobuf")
        ),
        AcknowledgementItem(
            title: "Google Promises for Swift",
            summary: "Asynchronous helper utilities. Apache License 2.0.",
            detail: """
Google Promises

Copyright 2017 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
""",
            website: URL(string: "https://github.com/google/promises")
        ),
        AcknowledgementItem(
            title: "LevelDB",
            summary: "Key–value storage used by Firebase caching. BSD 3-Clause License.",
            detail: """
LevelDB

Copyright (c) 2011 The LevelDB Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
3. Neither the name of Google Inc. nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
""",
            website: URL(string: "https://github.com/google/leveldb")
        ),
        AcknowledgementItem(
            title: "nanopb",
            summary: "Compact Protocol Buffers encoder/decoder. zlib License.",
            detail: """
nanopb

Copyright (c) 2011 Petteri Aimonen

This software is provided 'as-is', without any express or implied warranty. In no
event will the authors be held liable for any damages arising from the use of
this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to
the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim
   that you wrote the original software. If you use this software in a product,
   an acknowledgment in the product documentation would be appreciated but is
   not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
""",
            website: URL(string: "https://github.com/nanopb/nanopb")
        )
    ]
}

// MARK: - Detail View Controller

private final class AcknowledgementDetailViewController: UIViewController {

    private let item: AcknowledgementItem

    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.alwaysBounceVertical = true
        textView.backgroundColor = .systemBackground
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        return textView
    }()

    init(item: AcknowledgementItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = item.title

        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        var detailText = "\(item.summary)\n\n\(item.detail)"
        if let website = item.website {
            detailText.append("\nSource: \(website.absoluteString)")
        }
        textView.text = detailText

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Open Link",
            style: .plain,
            target: self,
            action: #selector(openLink)
        )
        navigationItem.rightBarButtonItem?.isEnabled = item.website != nil
    }

    @objc private func openLink() {
        guard let url = item.website else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Helpers

private extension UITableViewCell {
    static let reuseIdentifier = "AcknowledgementCell"
}

