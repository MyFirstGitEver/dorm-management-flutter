import 'package:flutter/material.dart';

class AbsoluteCollapseContainer extends StatelessWidget {
  final Widget child, appBar, header;

  const AbsoluteCollapseContainer({Key? key, required this.child, required this.appBar, required this.header}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
        return <Widget>[
          SliverOverlapAbsorber(
            handle:
            NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: appBar
          ),
          header
        ];
      },
      body: SafeArea(
        child: Builder(
            builder:(BuildContext context) {
              return CustomScrollView(
                slivers: <Widget>[
                  SliverOverlapInjector(
                    // This is the flip side of the SliverOverlapAbsorber above.
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  child,
                ],
              );
            }
        ),
      ),
    );
  }
}
