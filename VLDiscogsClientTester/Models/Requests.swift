//
//  Endpoints.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import OrderedCollections

struct Requests {
    // MARK: - Shared parameter constants

    private static let usernameParam = RequestParameter(
        id: "username", name: "Username", location: .path, autoFillKey: .username
    )
    private static let folderIdParam = RequestParameter(
        id: "folder_id", name: "Folder ID", location: .path, valueType: .int
    )
    private static let releaseIdParam = RequestParameter(
        id: "release_id", name: "Release ID", location: .path, valueType: .int
    )
    private static let instanceIdParam = RequestParameter(
        id: "instance_id", name: "Instance ID", location: .path, valueType: .int
    )
    private static let fieldIdParam = RequestParameter(
        id: "field_id", name: "Field ID", location: .path, valueType: .int
    )
    private static let pageParam = RequestParameter(
        id: "page", name: "Page", location: .query, valueType: .int, isRequired: false
    )
    private static let perPageParam = RequestParameter(
        id: "per_page", name: "Per Page", location: .query, valueType: .int, isRequired: false
    )
    private static let sortParam = RequestParameter(
        id: "sort", name: "Sort", location: .query,
        valueType: .enumeration(["label", "artist", "title", "catno", "format", "rating", "added", "year"]),
        isRequired: false
    )
    private static let sortOrderParam = RequestParameter(
        id: "sort_order", name: "Sort Order", location: .query,
        valueType: .enumeration(["asc", "desc"]),
        isRequired: false
    )

    // MARK: - Database-specific parameters

    private static let masterIdParam = RequestParameter(
        id: "master_id", name: "Master ID", location: .path, valueType: .int
    )
    private static let artistIdParam = RequestParameter(
        id: "artist_id", name: "Artist ID", location: .path, valueType: .int
    )
    private static let labelIdParam = RequestParameter(
        id: "label_id", name: "Label ID", location: .path, valueType: .int
    )

    // MARK: - User Identity endpoints

    static let userIdentity: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Identity"): [
            .init(id: 1, httpMethod: .get, path: "/oauth/identity")
        ],
        .init(id: 2, name: "Profile"): [
            .init(id: 2, httpMethod: .get, path: "/users/{username}",
                  parameters: [usernameParam]),
            .init(id: 3, httpMethod: .post, path: "/users/{username}",
                  parameters: [
                    usernameParam,
                    RequestParameter(id: "name", name: "Name", location: .body, isRequired: false),
                    RequestParameter(id: "home_page", name: "Home Page", location: .body, isRequired: false),
                    RequestParameter(id: "location", name: "Location", location: .body, isRequired: false),
                    RequestParameter(id: "profile", name: "Profile", location: .body, isRequired: false),
                    RequestParameter(id: "curr_abbr", name: "Currency", location: .body, isRequired: false)
                  ])
        ],
        .init(id: 3, name: "Submissions"): [
            .init(id: 4, httpMethod: .get, path: "/users/{username}/submissions",
                  parameters: [usernameParam, pageParam, perPageParam])
        ],
        .init(id: 4, name: "Contributions"): [
            .init(id: 5, httpMethod: .get, path: "/users/{username}/contributions",
                  parameters: [
                    usernameParam,
                    RequestParameter(
                        id: "sort", name: "Sort", location: .query,
                        valueType: .enumeration(["label", "artist", "title", "catno", "format", "rating", "added", "year"]),
                        isRequired: false
                    ),
                    sortOrderParam, pageParam, perPageParam
                  ])
        ]
    ]

    // MARK: - Database endpoints

    static let database: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Release"): [
            .init(id: 1, httpMethod: .get, path: "/releases/{release_id}",
                  parameters: [releaseIdParam])
        ],
        .init(id: 2, name: "Release Rating"): [
            .init(id: 2, httpMethod: .get, path: "/releases/{release_id}/rating/{username}",
                  parameters: [releaseIdParam, usernameParam]),
            .init(id: 3, httpMethod: .put, path: "/releases/{release_id}/rating/{username}",
                  parameters: [
                    releaseIdParam, usernameParam,
                    RequestParameter(id: "rating", name: "Rating", location: .body, valueType: .intRange(1...5))
                  ]),
            .init(id: 4, httpMethod: .delete, path: "/releases/{release_id}/rating/{username}",
                  parameters: [releaseIdParam, usernameParam])
        ],
        .init(id: 3, name: "Community Release Rating"): [
            .init(id: 5, httpMethod: .get, path: "/releases/{release_id}/rating",
                  parameters: [releaseIdParam])
        ],
        .init(id: 4, name: "Master Release"): [
            .init(id: 6, httpMethod: .get, path: "/masters/{master_id}",
                  parameters: [masterIdParam])
        ],
        .init(id: 5, name: "Master Release Versions"): [
            .init(id: 7, httpMethod: .get, path: "/masters/{master_id}/versions",
                  parameters: [masterIdParam, pageParam, perPageParam])
        ],
        .init(id: 6, name: "Artist"): [
            .init(id: 8, httpMethod: .get, path: "/artists/{artist_id}",
                  parameters: [artistIdParam])
        ],
        .init(id: 7, name: "Artist Releases"): [
            .init(id: 9, httpMethod: .get, path: "/artists/{artist_id}/releases",
                  parameters: [artistIdParam, sortParam, sortOrderParam, pageParam, perPageParam])
        ],
        .init(id: 8, name: "Label"): [
            .init(id: 10, httpMethod: .get, path: "/labels/{label_id}",
                  parameters: [labelIdParam])
        ],
        .init(id: 9, name: "Label Releases"): [
            .init(id: 11, httpMethod: .get, path: "/labels/{label_id}/releases",
                  parameters: [labelIdParam, sortParam, sortOrderParam, pageParam, perPageParam])
        ],
        .init(id: 10, name: "Search"): [
            .init(id: 12, httpMethod: .get, path: "/database/search",
                  parameters: [
                    RequestParameter(id: "q", name: "Query", location: .query),
                    RequestParameter(
                        id: "type", name: "Type", location: .query,
                        valueType: .enumeration(["release", "master", "artist", "label"]),
                        isRequired: false
                    ),
                    pageParam, perPageParam
                  ])
        ]
    ]

    // MARK: - Inventory Export endpoints

    static let inventoryExport: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Export Inventory"): [
            .init(id: 1, httpMethod: .post, path: "/inventory/export")
        ],
        .init(id: 2, name: "Recent Exports"): [
            .init(id: 2, httpMethod: .get, path: "/inventory/export",
                  parameters: [pageParam, perPageParam])
        ],
        .init(id: 3, name: "Get Export"): [
            .init(id: 3, httpMethod: .get, path: "/inventory/export/{id}",
                  parameters: [RequestParameter(id: "id", name: "Export ID", location: .path, valueType: .int)])
        ],
        .init(id: 4, name: "Download Export"): [
            .init(id: 4, httpMethod: .get, path: "/inventory/export/{id}/download",
                  parameters: [RequestParameter(id: "id", name: "Export ID", location: .path, valueType: .int)],
                  action: .downloadFile)
        ]
    ]

    // MARK: - Marketplace-specific parameters

    private static let listingIdParam = RequestParameter(
        id: "listing_id", name: "Listing ID", location: .path, valueType: .int
    )
    private static let orderIdParam = RequestParameter(
        id: "order_id", name: "Order ID", location: .path
    )
    private static let currAbbrParam = RequestParameter(
        id: "curr_abbr", name: "Currency", location: .query, isRequired: false
    )
    private static let listingStatusParam = RequestParameter(
        id: "status", name: "Status", location: .query,
        valueType: .enumeration(["For Sale", "Draft", "Expired", "Sold", "Deleted"]),
        isRequired: false
    )
    private static let conditionParam = RequestParameter(
        id: "condition", name: "Condition", location: .body,
        valueType: .enumeration([
            "Mint (M)", "Near Mint (NM or M-)", "Very Good Plus (VG+)",
            "Very Good (VG)", "Good Plus (G+)", "Good (G)",
            "Fair (F)", "Poor (P)", "Not Graded"
        ])
    )
    private static let sleeveConditionParam = RequestParameter(
        id: "sleeve_condition", name: "Sleeve Condition", location: .body,
        valueType: .enumeration([
            "Mint (M)", "Near Mint (NM or M-)", "Very Good Plus (VG+)",
            "Very Good (VG)", "Good Plus (G+)", "Good (G)",
            "Fair (F)", "Poor (P)", "Not Graded", "Generic Sleeve"
        ]),
        isRequired: false
    )
    private static let orderStatusParam = RequestParameter(
        id: "status", name: "Status", location: .query,
        valueType: .enumeration([
            "New Order", "Buyer Contacted", "Invoice Sent",
            "Payment Pending", "Payment Received", "Shipped",
            "Refund Sent", "Cancelled (Non-Paying Buyer)",
            "Cancelled (Item Unavailable)", "Cancelled (Per Buyer's Request)", "Merged"
        ]),
        isRequired: false
    )

    // MARK: - Marketplace endpoints

    static let marketplace: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Inventory"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/inventory",
                  parameters: [
                    usernameParam,
                    listingStatusParam,
                    RequestParameter(
                        id: "sort", name: "Sort", location: .query,
                        valueType: .enumeration(["listed", "price", "item", "artist", "label", "catno", "audio", "status", "location"]),
                        isRequired: false
                    ),
                    sortOrderParam, pageParam, perPageParam
                  ])
        ],
        .init(id: 2, name: "Listing"): [
            .init(id: 2, httpMethod: .get, path: "/marketplace/listings/{listing_id}",
                  parameters: [listingIdParam, currAbbrParam]),
            .init(id: 3, httpMethod: .post, path: "/marketplace/listings",
                  parameters: [
                    RequestParameter(id: "release_id", name: "Release ID", location: .body, valueType: .int),
                    conditionParam,
                    sleeveConditionParam,
                    RequestParameter(id: "price", name: "Price", location: .body),
                    RequestParameter(id: "status", name: "Status", location: .body,
                                     valueType: .enumeration(["For Sale", "Draft"])),
                    RequestParameter(id: "comments", name: "Comments", location: .body, isRequired: false),
                    RequestParameter(id: "allow_offers", name: "Allow Offers", location: .body,
                                     valueType: .enumeration(["true", "false"]), isRequired: false),
                    RequestParameter(id: "location", name: "Location", location: .body, isRequired: false),
                    RequestParameter(id: "weight", name: "Weight", location: .body, valueType: .int, isRequired: false),
                    RequestParameter(id: "format_quantity", name: "Format Quantity", location: .body, valueType: .int, isRequired: false)
                  ]),
            .init(id: 4, httpMethod: .post, path: "/marketplace/listings/{listing_id}",
                  parameters: [
                    listingIdParam,
                    RequestParameter(id: "release_id", name: "Release ID", location: .body, valueType: .int),
                    conditionParam,
                    sleeveConditionParam,
                    RequestParameter(id: "price", name: "Price", location: .body),
                    RequestParameter(id: "status", name: "Status", location: .body,
                                     valueType: .enumeration(["For Sale", "Draft"])),
                    RequestParameter(id: "comments", name: "Comments", location: .body, isRequired: false),
                    RequestParameter(id: "allow_offers", name: "Allow Offers", location: .body,
                                     valueType: .enumeration(["true", "false"]), isRequired: false),
                    RequestParameter(id: "location", name: "Location", location: .body, isRequired: false),
                    RequestParameter(id: "weight", name: "Weight", location: .body, valueType: .int, isRequired: false),
                    RequestParameter(id: "format_quantity", name: "Format Quantity", location: .body, valueType: .int, isRequired: false)
                  ]),
            .init(id: 5, httpMethod: .delete, path: "/marketplace/listings/{listing_id}",
                  parameters: [listingIdParam])
        ],
        .init(id: 3, name: "Orders"): [
            .init(id: 6, httpMethod: .get, path: "/marketplace/orders",
                  parameters: [
                    orderStatusParam,
                    RequestParameter(id: "archived", name: "Archived", location: .query,
                                     valueType: .enumeration(["true", "false"]), isRequired: false),
                    RequestParameter(
                        id: "sort", name: "Sort", location: .query,
                        valueType: .enumeration(["id", "buyer", "created", "status", "last_activity"]),
                        isRequired: false
                    ),
                    sortOrderParam, pageParam, perPageParam
                  ]),
            .init(id: 7, httpMethod: .get, path: "/marketplace/orders/{order_id}",
                  parameters: [orderIdParam]),
            .init(id: 8, httpMethod: .post, path: "/marketplace/orders/{order_id}",
                  parameters: [
                    orderIdParam,
                    RequestParameter(id: "status", name: "Status", location: .body,
                                     valueType: .enumeration([
                                        "New Order", "Buyer Contacted", "Invoice Sent",
                                        "Payment Pending", "Payment Received", "Shipped",
                                        "Refund Sent", "Cancelled (Non-Paying Buyer)",
                                        "Cancelled (Item Unavailable)", "Cancelled (Per Buyer's Request)", "Merged"
                                     ]),
                                     isRequired: false),
                    RequestParameter(id: "shipping", name: "Shipping Cost", location: .body, isRequired: false)
                  ])
        ],
        .init(id: 4, name: "Order Messages"): [
            .init(id: 9, httpMethod: .get, path: "/marketplace/orders/{order_id}/messages",
                  parameters: [orderIdParam, pageParam, perPageParam]),
            .init(id: 10, httpMethod: .post, path: "/marketplace/orders/{order_id}/messages",
                  parameters: [
                    orderIdParam,
                    RequestParameter(id: "message", name: "Message", location: .body, isRequired: false),
                    RequestParameter(id: "status", name: "Status", location: .body,
                                     valueType: .enumeration([
                                        "New Order", "Buyer Contacted", "Invoice Sent",
                                        "Payment Pending", "Payment Received", "Shipped",
                                        "Refund Sent", "Cancelled (Non-Paying Buyer)",
                                        "Cancelled (Item Unavailable)", "Cancelled (Per Buyer's Request)", "Merged"
                                     ]),
                                     isRequired: false)
                  ])
        ],
        .init(id: 5, name: "Fee"): [
            .init(id: 11, httpMethod: .get, path: "/marketplace/fee/{price}",
                  parameters: [RequestParameter(id: "price", name: "Price", location: .path)]),
            .init(id: 12, httpMethod: .get, path: "/marketplace/fee/{price}/{currency}",
                  parameters: [
                    RequestParameter(id: "price", name: "Price", location: .path),
                    RequestParameter(id: "currency", name: "Currency Code", location: .path)
                  ])
        ],
        .init(id: 6, name: "Price Suggestions"): [
            .init(id: 13, httpMethod: .get, path: "/marketplace/price_suggestions/{release_id}",
                  parameters: [releaseIdParam])
        ],
        .init(id: 7, name: "Release Statistics"): [
            .init(id: 14, httpMethod: .get, path: "/marketplace/stats/{release_id}",
                  parameters: [releaseIdParam, currAbbrParam])
        ]
    ]

    // MARK: - User Collection endpoints

    static let userCollection: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Collection"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/collection/folders",
                  parameters: [usernameParam]),
            .init(id: 2, httpMethod: .post, path: "/users/{username}/collection/folders",
                  parameters: [
                    usernameParam,
                    RequestParameter(id: "name", name: "Folder Name", location: .body)
                  ])
        ],
        .init(id: 2, name: "Collection Folders"): [
            .init(id: 3, httpMethod: .get, path: "/users/{username}/collection/folders/{folder_id}",
                  parameters: [usernameParam, folderIdParam]),
            .init(id: 4, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}",
                  parameters: [
                    usernameParam, folderIdParam,
                    RequestParameter(id: "name", name: "Folder Name", location: .body)
                  ]),
            .init(id: 5, httpMethod: .delete, path: "/users/{username}/collection/folders/{folder_id}",
                  parameters: [usernameParam, folderIdParam])
        ],
        .init(id: 3, name: "Collection Items By Release"): [
            .init(id: 6, httpMethod: .get, path: "/users/{username}/collection/releases/{release_id}",
                  parameters: [usernameParam, releaseIdParam])
        ],
        .init(id: 4, name: "Collection Items By Folder"): [
            .init(id: 7, httpMethod: .get, path: "/users/{username}/collection/folders/{folder_id}/releases",
                  parameters: [usernameParam, folderIdParam, sortParam, sortOrderParam, pageParam, perPageParam])
        ],
        .init(id: 5, name: "Add To Collection Folder"): [
            .init(id: 8, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}",
                  parameters: [usernameParam, folderIdParam, releaseIdParam])
        ],
        .init(id: 6, name: "Change Rating of Release"): [
            .init(id: 9, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}/instances/{instance_id}",
                  parameters: [
                    usernameParam, folderIdParam, releaseIdParam, instanceIdParam,
                    RequestParameter(id: "rating", name: "Rating", location: .body, valueType: .intRange(1...5))
                  ])
        ],
        .init(id: 7, name: "Delete Instance From Folder"): [
            .init(id: 10, httpMethod: .delete, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}/instances/{instance_id}",
                  parameters: [usernameParam, folderIdParam, releaseIdParam, instanceIdParam])
        ],
        .init(id: 8, name: "List Custom Fields"): [
            .init(id: 11, httpMethod: .get, path: "/users/{username}/collection/fields",
                  parameters: [usernameParam])
        ],
        .init(id: 9, name: "Edit Fields Instance"): [
            .init(id: 12, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}/instances/{instance_id}/fields/{field_id}{?value}",
                  parameters: [
                    usernameParam, folderIdParam, releaseIdParam, instanceIdParam, fieldIdParam,
                    RequestParameter(id: "value", name: "Value", location: .query)
                  ])
        ],
        .init(id: 10, name: "Collection Value"): [
            .init(id: 13, httpMethod: .get, path: "/users/{username}/collection/value",
                  parameters: [usernameParam])
        ]
    ]
}
