import SwiftUI
import Kingfisher
import FirebaseFirestore

struct ReportTarget: Identifiable { let id: String }

struct CommunityView: View {
    @EnvironmentObject var commentService  : CommentService
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var favoriteService: FavoriteService
    @EnvironmentObject var voteService  : VoteService
    @State private var selectedYokai : Ayakasi? = nil
    @State private var navigationPath: [Ayakasi] = []
    @State private var selectedCommentId : String = ""
    @State private var reportTarget: ReportTarget? = nil
    var body: some View {
        NavigationStack(path: $navigationPath){
            ScrollView{
                RecentCommentsSectionView(
                    selectedYokai: $selectedYokai,
                    selectedCommentId: $selectedCommentId,
                    reportTarget: $reportTarget
                )
            }
            .onAppear{
                Task{
                    await commentService.getRecentCommentsIfNeeded()
                    await favoriteService.fetchBookmarkCommentIdsIfNeeded()
                }
            }
            .onChange(of: selectedYokai) { _, yokai in
                guard let yokai else { return }
                navigationPath.append(yokai)
                selectedYokai = nil
            }
            .refreshable {
                await commentService.getRecentComments()
                try? await favoriteService.fetchBookmarkCommentIds()
            }
            .navigationDestination(for: Ayakasi.self) { yokai in
                NeoDetail(yokai: yokai)
            }
            .sheet(item: $reportTarget) { target in
                if let comment = commentService.recentComments.first(where: { ($0["documentId"] as? String) == target.id }),
                   let userId = comment["userId"] as? String {
                    ReportUI(commentId: target.id, userId: userId)
                        .presentationDetents([.height(220)])
                        .presentationBackground(Color.appBackground)
                        .presentationCornerRadius(36)
                }
            }
        }
    }
}
