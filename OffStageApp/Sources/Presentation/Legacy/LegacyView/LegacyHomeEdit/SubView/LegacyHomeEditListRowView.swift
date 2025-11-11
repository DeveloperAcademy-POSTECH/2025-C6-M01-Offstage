import SwiftUI

struct LegacyHomeEditListRowView: View {
    let nodeName: String
    let nodeNo: String?
    let routes: [String]

    // 색상팔레트 나오면 다음상수 없애고 지정하기
    let tertiary = Color(red: 0.73, green: 0.74, blue: 0.78)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(nodeName)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(nodeNo ?? "")
                    .font(.callout)
                    .foregroundColor(.gray)

                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "bus.fill")
                        .font(.footnote)
                        .foregroundStyle(tertiary)

                    Text(routes.joined(separator: ", "))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
    }
}

#Preview {
    LegacyHomeEditListRowView(
        nodeName: "생명공학연구소",
        nodeNo: "299002",
        routes: ["207", "306"]
    )
}
