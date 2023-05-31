//
//  HomeView.swift
//  DesignCode
//
//  Created by Jmy on 2023/05/31.
//

import SwiftUI

struct HomeView: View {
    @State var hasScrolled = false
    @Namespace var namespace
    @State var show = false

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            ScrollView {
//                scrollDetection

                featured

                Text("Courses".uppercased())
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                if !show {
                    CourseItem(namespace: namespace, show: $show)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                show.toggle()
                            }
                        }
                }
            }
            .coordinateSpace(name: "scroll")
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 70)
            }
            .overlay {
                NavigationBar(title: "Featured", hasScrolled: $hasScrolled)
            }

            if show {
                CourseView(namespace: namespace, show: $show)
            }
        }
    }

//    var scrollDetection: some View {
//        GeometryReader { proxy in
//            Text("\(proxy.frame(in: .named("scroll")).minY)")
//            Color.clear.preference(value: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
//        }
//        .frame(height: 0)
//    }

    var featured: some View {
        TabView {
            ForEach(courses) { course in
                GeometryReader { proxy in
                    let minX = proxy.frame(in: .global).minX

                    FeaturedItem(course: course)
                        .padding(.vertical, 40)
//                        .rotation3DEffect(.degrees(10), axis: (x: 1, y: 1, z: 1))
//                        .rotation3DEffect(.degrees(minX), axis: (x: 1, y: 1, z: 1))
                        .rotation3DEffect(.degrees(minX / -10), axis: (x: 0, y: 1, z: 0))
                        .shadow(color: Color("Shadow").opacity(0.3), radius: 10, x: 0, y: 10)
                        .blur(radius: abs(minX / 40))
                        .overlay(
                            Image(course.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 250, maxHeight: 250)
                                .offset(x: 32, y: -100)
                                .offset(x: minX / 2)
                        )

//                    Text("\(minX)")
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 430)
        .background(
            Image("COMINGSOON")
                .offset(x: 250, y: -100)
                .opacity(0.5)
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
