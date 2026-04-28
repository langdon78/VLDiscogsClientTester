//
//  Endpoints.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import Foundation
import OrderedCollections
import VLDiscogsClient

struct Requests {
    // MARK: - Helpers

    private static func encode<T: Encodable>(
        _ block: @escaping (VLDiscogsClient, [String: String], [RequestParameter.AutoFillKey: String]) async throws -> T
    ) -> RequestUrlTemplate.APIAction {
        { client, values, autoFill in
            try JSONEncoder().encode(try await block(client, values, autoFill))
        }
    }

    private static func action(
        _ block: @escaping (VLDiscogsClient, [String: String], [RequestParameter.AutoFillKey: String]) async throws -> Void
    ) -> RequestUrlTemplate.APIAction {
        { client, values, autoFill in
            try await block(client, values, autoFill)
            return Data("{}".utf8)
        }
    }

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
            .init(id: 1, httpMethod: .get, path: "/oauth/identity",
                  execute: encode { c, _, _ in try await c.userIdentityApi.getIdentity() })
        ],
        .init(id: 2, name: "Profile"): [
            .init(id: 2, httpMethod: .get, path: "/users/{username}",
                  parameters: [usernameParam],
                  execute: encode { c, _, a in
                      try await c.userIdentityApi.getProfile(username: a.username)
                  }),
            .init(id: 3, httpMethod: .post, path: "/users/{username}",
                  parameters: [
                    usernameParam,
                    RequestParameter(id: "name", name: "Name", location: .body, isRequired: false),
                    RequestParameter(id: "home_page", name: "Home Page", location: .body, isRequired: false),
                    RequestParameter(id: "location", name: "Location", location: .body, isRequired: false),
                    RequestParameter(id: "profile", name: "Profile", location: .body, isRequired: false),
                    RequestParameter(id: "curr_abbr", name: "Currency", location: .body, isRequired: false)
                  ],
                  execute: encode { c, v, a in
                      try await c.userIdentityApi.editProfile(
                          username: a.username,
                          name: v.opt("name"),
                          homePage: v.opt("home_page"),
                          location: v.opt("location"),
                          profile: v.opt("profile"),
                          currAbbr: v.opt("curr_abbr")
                      )
                  })
        ],
        .init(id: 3, name: "Submissions"): [
            .init(id: 4, httpMethod: .get, path: "/users/{username}/submissions",
                  parameters: [usernameParam, pageParam, perPageParam],
                  execute: encode { c, v, a in
                      try await c.userIdentityApi.getSubmissions(
                          username: a.username,
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  })
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
                  ],
                  execute: encode { c, v, a in
                      try await c.userIdentityApi.getContributions(
                          username: a.username,
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page"),
                          sort: v.opt("sort"),
                          sortOrder: v.opt("sort_order")
                      )
                  })
        ]
    ]

    // MARK: - Database endpoints

    static let database: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Release"): [
            .init(id: 1, httpMethod: .get, path: "/releases/{release_id}",
                  parameters: [releaseIdParam],
                  execute: encode { c, v, _ in try await c.databaseApi.release(id: v.reqInt("release_id")) })
        ],
        .init(id: 2, name: "Release Rating"): [
            .init(id: 2, httpMethod: .get, path: "/releases/{release_id}/rating/{username}",
                  parameters: [releaseIdParam, usernameParam],
                  execute: encode { c, v, a in
                      try await c.databaseApi.releaseRating(releaseId: v.reqInt("release_id"), username: a.username)
                  }),
            .init(id: 3, httpMethod: .put, path: "/releases/{release_id}/rating/{username}",
                  parameters: [
                    releaseIdParam, usernameParam,
                    RequestParameter(id: "rating", name: "Rating", location: .body, valueType: .intRange(1...5))
                  ],
                  execute: encode { c, v, a in
                      try await c.databaseApi.updateReleaseRating(
                          releaseId: v.reqInt("release_id"),
                          username: a.username,
                          rating: v.reqInt("rating")
                      )
                  }),
            .init(id: 4, httpMethod: .delete, path: "/releases/{release_id}/rating/{username}",
                  parameters: [releaseIdParam, usernameParam],
                  execute: action { c, v, a in
                      try await c.databaseApi.deleteReleaseRating(releaseId: v.reqInt("release_id"), username: a.username)
                  })
        ],
        .init(id: 3, name: "Community Release Rating"): [
            .init(id: 5, httpMethod: .get, path: "/releases/{release_id}/rating",
                  parameters: [releaseIdParam],
                  execute: encode { c, v, _ in
                      try await c.databaseApi.communityReleaseRating(releaseId: v.reqInt("release_id"))
                  })
        ],
        .init(id: 4, name: "Master Release"): [
            .init(id: 6, httpMethod: .get, path: "/masters/{master_id}",
                  parameters: [masterIdParam],
                  execute: encode { c, v, _ in try await c.databaseApi.master(id: v.reqInt("master_id")) })
        ],
        .init(id: 5, name: "Master Release Versions"): [
            .init(id: 7, httpMethod: .get, path: "/masters/{master_id}/versions",
                  parameters: [masterIdParam, pageParam, perPageParam],
                  execute: encode { c, v, _ in
                      try await c.databaseApi.masterVersions(
                          masterId: v.reqInt("master_id"),
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  })
        ],
        .init(id: 6, name: "Artist"): [
            .init(id: 8, httpMethod: .get, path: "/artists/{artist_id}",
                  parameters: [artistIdParam],
                  execute: encode { c, v, _ in try await c.databaseApi.artist(id: v.reqInt("artist_id")) })
        ],
        .init(id: 7, name: "Artist Releases"): [
            .init(id: 9, httpMethod: .get, path: "/artists/{artist_id}/releases",
                  parameters: [artistIdParam, sortParam, sortOrderParam, pageParam, perPageParam],
                  execute: encode { c, v, _ in
                      try await c.databaseApi.artistReleases(
                          artistId: v.reqInt("artist_id"),
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page"),
                          sort: v.opt("sort").flatMap { DiscogsEndpoint.SortParameterValue(rawValue: $0) },
                          sortOrder: v.opt("sort_order").flatMap { DiscogsEndpoint.SortOrderParameterValue(rawValue: $0) }
                      )
                  })
        ],
        .init(id: 8, name: "Label"): [
            .init(id: 10, httpMethod: .get, path: "/labels/{label_id}",
                  parameters: [labelIdParam],
                  execute: encode { c, v, _ in try await c.databaseApi.label(id: v.reqInt("label_id")) })
        ],
        .init(id: 9, name: "Label Releases"): [
            .init(id: 11, httpMethod: .get, path: "/labels/{label_id}/releases",
                  parameters: [labelIdParam, sortParam, sortOrderParam, pageParam, perPageParam],
                  execute: encode { c, v, _ in
                      try await c.databaseApi.labelReleases(
                          labelId: v.reqInt("label_id"),
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page"),
                          sort: v.opt("sort").flatMap { DiscogsEndpoint.SortParameterValue(rawValue: $0) },
                          sortOrder: v.opt("sort_order").flatMap { DiscogsEndpoint.SortOrderParameterValue(rawValue: $0) }
                      )
                  })
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
                  ],
                  execute: encode { c, v, _ in
                      try await c.databaseApi.search(
                          query: v["q"]!,
                          type: v.opt("type").flatMap { DiscogsEndpoint.SearchType(rawValue: $0) },
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  })
        ]
    ]

    // MARK: - User Wantlist endpoints

    static let userWantlist: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Wantlist"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/wants",
                  parameters: [usernameParam, pageParam, perPageParam],
                  execute: encode { c, v, a in
                      try await c.wantlistApi.wantlist(
                          username: a.username,
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  })
        ],
        .init(id: 2, name: "Add to Wantlist"): [
            .init(id: 2, httpMethod: .put, path: "/users/{username}/wants/{release_id}",
                  parameters: [
                    usernameParam, releaseIdParam,
                    RequestParameter(id: "notes", name: "Notes", location: .body, isRequired: false),
                    RequestParameter(id: "rating", name: "Rating", location: .body, valueType: .intRange(1...5), isRequired: false)
                  ],
                  execute: encode { c, v, a in
                      try await c.wantlistApi.addToWantlist(
                          username: a.username,
                          releaseId: v.reqInt("release_id"),
                          notes: v.opt("notes"),
                          rating: v.optInt("rating")
                      )
                  })
        ],
        .init(id: 3, name: "Edit Wantlist Item"): [
            .init(id: 3, httpMethod: .post, path: "/users/{username}/wants/{release_id}",
                  parameters: [
                    usernameParam, releaseIdParam,
                    RequestParameter(id: "notes", name: "Notes", location: .body, isRequired: false),
                    RequestParameter(id: "rating", name: "Rating", location: .body, valueType: .intRange(1...5), isRequired: false)
                  ],
                  execute: encode { c, v, a in
                      try await c.wantlistApi.editWantlistItem(
                          username: a.username,
                          releaseId: v.reqInt("release_id"),
                          notes: v.opt("notes"),
                          rating: v.optInt("rating")
                      )
                  })
        ],
        .init(id: 4, name: "Delete from Wantlist"): [
            .init(id: 4, httpMethod: .delete, path: "/users/{username}/wants/{release_id}",
                  parameters: [usernameParam, releaseIdParam],
                  execute: action { c, v, a in
                      try await c.wantlistApi.deleteFromWantlist(username: a.username, releaseId: v.reqInt("release_id"))
                  })
        ]
    ]

    // MARK: - User Lists endpoints

    private static let listIdParam = RequestParameter(
        id: "list_id", name: "List ID", location: .path, valueType: .int
    )

    static let userLists: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "User Lists"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/lists",
                  parameters: [usernameParam, pageParam, perPageParam],
                  execute: encode { c, v, a in
                      try await c.userListsApi.lists(
                          username: a.username,
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  })
        ],
        .init(id: 2, name: "List Details"): [
            .init(id: 2, httpMethod: .get, path: "/lists/{list_id}",
                  parameters: [listIdParam],
                  execute: encode { c, v, _ in try await c.userListsApi.list(id: v.reqInt("list_id")) })
        ]
    ]

    // MARK: - Inventory Upload endpoints

    static let inventoryUpload: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Recent Uploads"): [
            .init(id: 1, httpMethod: .get, path: "/inventory/upload",
                  parameters: [pageParam, perPageParam],
                  execute: encode { c, v, _ in
                      try await c.inventoryUploadApi.recentUploads(
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  })
        ],
        .init(id: 2, name: "Get Upload"): [
            .init(id: 2, httpMethod: .get, path: "/inventory/upload/{id}",
                  parameters: [RequestParameter(id: "id", name: "Upload ID", location: .path, valueType: .int)],
                  execute: encode { c, v, _ in try await c.inventoryUploadApi.upload(id: v.reqInt("id")) })
        ],
        .init(id: 3, name: "Upload Inventory"): [
            .init(id: 3, httpMethod: .post, path: "/inventory/upload/{type}",
                  parameters: [
                    RequestParameter(
                        id: "type", name: "Type", location: .path,
                        valueType: .enumeration(["add", "change", "delete"])
                    )
                  ])
        ]
    ]

    // MARK: - Inventory Export endpoints

    static let inventoryExport: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Export Inventory"): [
            .init(id: 1, httpMethod: .post, path: "/inventory/export",
                  execute: encode { c, _, _ in try await c.inventoryExportApi.requestExport() })
        ],
        .init(id: 2, name: "Recent Exports"): [
            .init(id: 2, httpMethod: .get, path: "/inventory/export",
                  parameters: [pageParam, perPageParam],
                  execute: encode { c, v, _ in
                      try await c.inventoryExportApi.recentExports(
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  })
        ],
        .init(id: 3, name: "Get Export"): [
            .init(id: 3, httpMethod: .get, path: "/inventory/export/{id}",
                  parameters: [RequestParameter(id: "id", name: "Export ID", location: .path, valueType: .int)],
                  execute: encode { c, v, _ in try await c.inventoryExportApi.export(id: v.reqInt("id")) })
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
                  ],
                  execute: encode { c, v, a in
                      try await c.marketplaceApi.inventory(
                          username: a.username,
                          status: v.opt("status").flatMap { DiscogsEndpoint.ListingStatus(rawValue: $0) },
                          sort: v.opt("sort").flatMap { DiscogsEndpoint.InventorySortField(rawValue: $0) },
                          sortOrder: v.opt("sort_order").flatMap { DiscogsEndpoint.SortOrderParameterValue(rawValue: $0) },
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  })
        ],
        .init(id: 2, name: "Listing"): [
            .init(id: 2, httpMethod: .get, path: "/marketplace/listings/{listing_id}",
                  parameters: [listingIdParam, currAbbrParam],
                  execute: encode { c, v, _ in
                      try await c.marketplaceApi.listing(id: v.reqInt("listing_id"), currAbbr: v.opt("curr_abbr"))
                  }),
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
                  ],
                  execute: encode { c, v, _ in
                      try await c.marketplaceApi.createListing(
                          releaseId: v.reqInt("release_id"),
                          condition: DiscogsEndpoint.ReleaseCondition(rawValue: v["condition"]!)!,
                          sleeveCondition: v.opt("sleeve_condition").flatMap { DiscogsEndpoint.ReleaseCondition(rawValue: $0) },
                          price: Double(v["price"]!)!,
                          status: DiscogsEndpoint.ListingStatus(rawValue: v["status"]!)!,
                          comments: v.opt("comments"),
                          allowOffers: v.opt("allow_offers").flatMap(Bool.init),
                          location: v.opt("location"),
                          weight: v.optInt("weight"),
                          formatQuantity: v.optInt("format_quantity")
                      )
                  }),
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
                  ],
                  execute: action { c, v, _ in
                      try await c.marketplaceApi.editListing(
                          id: v.reqInt("listing_id"),
                          releaseId: v.reqInt("release_id"),
                          condition: DiscogsEndpoint.ReleaseCondition(rawValue: v["condition"]!)!,
                          sleeveCondition: v.opt("sleeve_condition").flatMap { DiscogsEndpoint.ReleaseCondition(rawValue: $0) },
                          price: Double(v["price"]!)!,
                          status: DiscogsEndpoint.ListingStatus(rawValue: v["status"]!)!,
                          comments: v.opt("comments"),
                          allowOffers: v.opt("allow_offers").flatMap(Bool.init),
                          location: v.opt("location"),
                          weight: v.optInt("weight"),
                          formatQuantity: v.optInt("format_quantity")
                      )
                  }),
            .init(id: 5, httpMethod: .delete, path: "/marketplace/listings/{listing_id}",
                  parameters: [listingIdParam],
                  execute: action { c, v, _ in try await c.marketplaceApi.deleteListing(id: v.reqInt("listing_id")) })
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
                  ],
                  execute: encode { c, v, _ in
                      try await c.marketplaceApi.orders(
                          status: v.opt("status").flatMap { DiscogsEndpoint.OrderStatus(rawValue: $0) },
                          archived: v.opt("archived").flatMap(Bool.init),
                          sort: v.opt("sort").flatMap { DiscogsEndpoint.OrderSortField(rawValue: $0) },
                          sortOrder: v.opt("sort_order").flatMap { DiscogsEndpoint.SortOrderParameterValue(rawValue: $0) },
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  }),
            .init(id: 7, httpMethod: .get, path: "/marketplace/orders/{order_id}",
                  parameters: [orderIdParam],
                  execute: encode { c, v, _ in try await c.marketplaceApi.order(id: v["order_id"]!) }),
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
                  ],
                  execute: encode { c, v, _ in
                      try await c.marketplaceApi.editOrder(
                          id: v["order_id"]!,
                          status: v.opt("status").flatMap { DiscogsEndpoint.OrderStatus(rawValue: $0) },
                          shipping: v.optDouble("shipping")
                      )
                  })
        ],
        .init(id: 4, name: "Order Messages"): [
            .init(id: 9, httpMethod: .get, path: "/marketplace/orders/{order_id}/messages",
                  parameters: [orderIdParam, pageParam, perPageParam],
                  execute: encode { c, v, _ in
                      try await c.marketplaceApi.orderMessages(
                          orderId: v["order_id"]!,
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page")
                      )
                  }),
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
                  ],
                  execute: encode { c, v, _ in
                      try await c.marketplaceApi.createOrderMessage(
                          orderId: v["order_id"]!,
                          message: v.opt("message"),
                          status: v.opt("status").flatMap { DiscogsEndpoint.OrderStatus(rawValue: $0) }
                      )
                  })
        ],
        .init(id: 5, name: "Fee"): [
            .init(id: 11, httpMethod: .get, path: "/marketplace/fee/{price}",
                  parameters: [RequestParameter(id: "price", name: "Price", location: .path)],
                  execute: encode { c, v, _ in try await c.marketplaceApi.fee(price: Double(v["price"]!)!) }),
            .init(id: 12, httpMethod: .get, path: "/marketplace/fee/{price}/{currency}",
                  parameters: [
                    RequestParameter(id: "price", name: "Price", location: .path),
                    RequestParameter(id: "currency", name: "Currency Code", location: .path)
                  ],
                  execute: encode { c, v, _ in try await c.marketplaceApi.fee(price: Double(v["price"]!)!, currency: v["currency"]!) })
        ],
        .init(id: 6, name: "Price Suggestions"): [
            .init(id: 13, httpMethod: .get, path: "/marketplace/price_suggestions/{release_id}",
                  parameters: [releaseIdParam],
                  execute: encode { c, v, _ in try await c.marketplaceApi.priceSuggestions(releaseId: v.reqInt("release_id")) })
        ],
        .init(id: 7, name: "Release Statistics"): [
            .init(id: 14, httpMethod: .get, path: "/marketplace/stats/{release_id}",
                  parameters: [releaseIdParam, currAbbrParam],
                  execute: encode { c, v, _ in
                      try await c.marketplaceApi.releaseStatistics(releaseId: v.reqInt("release_id"), currAbbr: v.opt("curr_abbr"))
                  })
        ]
    ]

    // MARK: - User Collection endpoints

    static let userCollection: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Collection"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/collection/folders",
                  parameters: [usernameParam],
                  execute: encode { c, _, _ in try await c.userCollectionApi.collectionFolders() }),
            .init(id: 2, httpMethod: .post, path: "/users/{username}/collection/folders",
                  parameters: [
                    usernameParam,
                    RequestParameter(id: "name", name: "Folder Name", location: .body)
                  ],
                  execute: encode { c, v, _ in try await c.userCollectionApi.createFolder(name: v["name"]!) })
        ],
        .init(id: 2, name: "Collection Folders"): [
            .init(id: 3, httpMethod: .get, path: "/users/{username}/collection/folders/{folder_id}",
                  parameters: [usernameParam, folderIdParam],
                  execute: encode { c, v, _ in try await c.userCollectionApi.collectionFolder(folderId: v.reqInt("folder_id")) }),
            .init(id: 4, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}",
                  parameters: [
                    usernameParam, folderIdParam,
                    RequestParameter(id: "name", name: "Folder Name", location: .body)
                  ],
                  execute: encode { c, v, _ in
                      try await c.userCollectionApi.updateFolder(folderId: v.reqInt("folder_id"), name: v["name"]!)
                  }),
            .init(id: 5, httpMethod: .delete, path: "/users/{username}/collection/folders/{folder_id}",
                  parameters: [usernameParam, folderIdParam],
                  execute: action { c, v, _ in try await c.userCollectionApi.deleteFolder(folderId: v.reqInt("folder_id")) })
        ],
        .init(id: 3, name: "Collection Items By Release"): [
            .init(id: 6, httpMethod: .get, path: "/users/{username}/collection/releases/{release_id}",
                  parameters: [usernameParam, releaseIdParam],
                  execute: encode { c, v, _ in
                      try await c.userCollectionApi.collectionItemsByRelease(releaseId: v.reqInt("release_id"))
                  })
        ],
        .init(id: 4, name: "Collection Items By Folder"): [
            .init(id: 7, httpMethod: .get, path: "/users/{username}/collection/folders/{folder_id}/releases",
                  parameters: [usernameParam, folderIdParam, sortParam, sortOrderParam, pageParam, perPageParam],
                  execute: encode { c, v, _ in
                      try await c.userCollectionApi.collectionItemsByFolder(
                          folderId: v.reqInt("folder_id"),
                          page: v.optInt("page"),
                          perPage: v.optInt("per_page"),
                          sort: v.opt("sort").flatMap { DiscogsEndpoint.SortParameterValue(rawValue: $0) },
                          sortOrder: v.opt("sort_order").flatMap { DiscogsEndpoint.SortOrderParameterValue(rawValue: $0) }
                      )
                  })
        ],
        .init(id: 5, name: "Add To Collection Folder"): [
            .init(id: 8, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}",
                  parameters: [usernameParam, folderIdParam, releaseIdParam],
                  execute: encode { c, v, _ in
                      try await c.userCollectionApi.addReleaseToFolder(releaseId: v.reqInt("release_id"), folderId: v.reqInt("folder_id"))
                  })
        ],
        .init(id: 6, name: "Change Rating of Release"): [
            .init(id: 9, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}/instances/{instance_id}",
                  parameters: [
                    usernameParam, folderIdParam, releaseIdParam, instanceIdParam,
                    RequestParameter(id: "rating", name: "Rating", location: .body, valueType: .intRange(1...5))
                  ],
                  execute: action { c, v, _ in
                      try await c.userCollectionApi.changeRating(
                          folderId: v.reqInt("folder_id"),
                          releaseId: v.reqInt("release_id"),
                          instanceId: v.reqInt("instance_id"),
                          rating: v.reqInt("rating")
                      )
                  })
        ],
        .init(id: 7, name: "Delete Instance From Folder"): [
            .init(id: 10, httpMethod: .delete, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}/instances/{instance_id}",
                  parameters: [usernameParam, folderIdParam, releaseIdParam, instanceIdParam],
                  execute: action { c, v, _ in
                      try await c.userCollectionApi.deleteReleaseInstance(
                          folderId: v.reqInt("folder_id"),
                          releaseId: v.reqInt("release_id"),
                          instanceId: v.reqInt("instance_id")
                      )
                  })
        ],
        .init(id: 8, name: "List Custom Fields"): [
            .init(id: 11, httpMethod: .get, path: "/users/{username}/collection/fields",
                  parameters: [usernameParam],
                  execute: encode { c, _, _ in try await c.userCollectionApi.customFields() })
        ],
        .init(id: 9, name: "Edit Fields Instance"): [
            .init(id: 12, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}/instances/{instance_id}/fields/{field_id}{?value}",
                  parameters: [
                    usernameParam, folderIdParam, releaseIdParam, instanceIdParam, fieldIdParam,
                    RequestParameter(id: "value", name: "Value", location: .query)
                  ],
                  execute: action { c, v, _ in
                      try await c.userCollectionApi.editInstanceField(
                          folderId: v.reqInt("folder_id"),
                          releaseId: v.reqInt("release_id"),
                          instanceId: v.reqInt("instance_id"),
                          fieldId: v.reqInt("field_id"),
                          value: v["value"]!
                      )
                  })
        ],
        .init(id: 10, name: "Collection Value"): [
            .init(id: 13, httpMethod: .get, path: "/users/{username}/collection/value",
                  parameters: [usernameParam],
                  execute: encode { c, _, _ in try await c.userCollectionApi.collectionValue() })
        ]
    ]
}

// MARK: - Parameter value helpers

private extension Dictionary where Key == String, Value == String {
    func opt(_ key: String) -> String? {
        guard let v = self[key], !v.isEmpty else { return nil }
        return v
    }

    func reqInt(_ key: String) -> Int { Int(self[key]!)! }
    func optInt(_ key: String) -> Int? { opt(key).flatMap(Int.init) }
    func optDouble(_ key: String) -> Double? { opt(key).flatMap(Double.init) }
}

private extension Dictionary where Key == RequestParameter.AutoFillKey, Value == String {
    var username: String { self[.username] ?? "" }
}
