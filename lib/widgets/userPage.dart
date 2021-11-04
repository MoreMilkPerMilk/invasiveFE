import 'package:flutter/material.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:invasive_fe/widgets/reportPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:string_similarity/string_similarity.dart';

Map<int, Species> species = {};
RefreshController _refreshController = RefreshController(initialRefresh: false);

// todo change to reports by user.
class UserPage extends StatefulWidget {
  UserPage();

  @override
  _UserPageState createState() => new _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Report> reports = [];
  Map<String, List<Report>> organisedReports = {};
  late Future loaded;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    print("done refreshing");
    List<Report> newReports = await getAllReports();
    organisedReports = {};
    newReports.forEach((report) {
      var speciesName = species[report.species_id]!.name;
      if (organisedReports.containsKey(speciesName)) {
        organisedReports[speciesName]!.add(report);
      } else {
        organisedReports[speciesName] = [report];
      }
    });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    print("done loading");
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    Future reportsFuture = getAllReports();
    //use current user reports
    // userFuture.then((User u) => reports = u.reports);

    Future speciesFuture = getAllSpecies();
    reportsFuture.then((value) => reports = value);

    speciesFuture.then((speciesList) {
      // create the {species id => species} map
      species = Map.fromIterable(speciesList, // convert species list to map for quick id lookup
          key: (e) => e.species_id,
          value: (e) => e);

      // organise the species into groups
    });

    // group the notifications
    loaded = Future.wait([reportsFuture, speciesFuture]).then((value) {
      reports.forEach((report) {
        var speciesName = species[report.species_id]!.name;
        if (organisedReports.containsKey(speciesName)) {
          organisedReports[speciesName]!.add(report);
        } else {
          organisedReports[speciesName] = [report];
        }
      });
      return value;
    });
    // loaded = Future.wait([reportsFuture, speciesFuture]);
  }

  String bestPlantImage(String speciesName) {
    List<String> weeds = [
      'assets/weeds/polka_dot_plant.jpg',
      'assets/weeds/prickly_pear_.jpg',
      'assets/weeds/zebrina.jpg',
      'assets/weeds/south_african_pigeon_grass.jpg',
      'assets/weeds/guinea_grass.jpg',
      'assets/weeds/dutchman&#039;s_pipe.jpg',
      'assets/weeds/siratro.jpg',
      'assets/weeds/himalayan_ash.jpg',
      'assets/weeds/mother-of-thousands.jpg',
      'assets/weeds/mouse-ear_chickweed.jpg',
      'assets/weeds/red_caustic_weed.jpg',
      'assets/weeds/serrated_tussock.jpg',
      'assets/weeds/gorse.jpg',
      'assets/weeds/feathertop_rhodes_grass.jpg',
      'assets/weeds/drooping_tree_pear.jpg',
      'assets/weeds/japanese_honeysuckle.jpg',
      'assets/weeds/papyrus.jpg',
      'assets/weeds/honey_mesquite.jpg',
      'assets/weeds/candleberry_myrtle.jpg',
      'assets/weeds/pink_periwinkle.jpg',
      'assets/weeds/praxelis.jpg',
      'assets/weeds/spear_thistle.jpg',
      'assets/weeds/condamine_couch.jpg',
      'assets/weeds/capeweed.jpg',
      'assets/weeds/mock_orange.jpg',
      'assets/weeds/feathertop.jpg',
      'assets/weeds/kochia.jpg',
      'assets/weeds/mother-of-millions.jpg',
      'assets/weeds/kahili_ginger.jpg',
      'assets/weeds/zig-zag_wattle.jpg',
      'assets/weeds/sicklethorn.jpg',
      'assets/weeds/horned_melon.jpg',
      'assets/weeds/green_cestrum.jpg',
      'assets/weeds/sourgrass.jpg',
      'assets/weeds/eve’s_pin_cactus.jpg',
      'assets/weeds/little_bluestem.jpg',
      'assets/weeds/cape_water_lily.jpg',
      'assets/weeds/resurrection_plant.jpg',
      'assets/weeds/fire_flag.jpg',
      'assets/weeds/sicklebush.jpg',
      'assets/weeds/aerial_yam.jpg',
      'assets/weeds/easter_cassia.jpg',
      'assets/weeds/common_vetch.jpg',
      'assets/weeds/fireweed.jpg',
      'assets/weeds/honey_locust.jpg',
      'assets/weeds/pond_apple.jpg',
      'assets/weeds/fragrant_thunbergia.jpg',
      'assets/weeds/golden_chain_tree.jpg',
      'assets/weeds/century_plant.jpg',
      'assets/weeds/khaki_weed.jpg',
      'assets/weeds/white_ginger.jpg',
      'assets/weeds/castor_oil_plant.jpg',
      'assets/weeds/pink_tephrosia.jpg',
      'assets/weeds/cane_cactus.jpg',
      'assets/weeds/singapore_daisy.jpg',
      'assets/weeds/creeping_lantana.jpg',
      'assets/weeds/syngonium.jpg',
      'assets/weeds/annual_thunbergia.jpg',
      'assets/weeds/wandering_dude.jpg',
      'assets/weeds/rhus_tree.jpg',
      'assets/weeds/chinese_burr.jpg',
      'assets/weeds/mossman_river_grass.jpg',
      'assets/weeds/paper_mulberry.jpg',
      'assets/weeds/jacaranda.jpg',
      'assets/weeds/mikania.jpg',
      'assets/weeds/cobbler&#039;s_pegs.jpg',
      'assets/weeds/bitter_melon.jpg',
      'assets/weeds/golden_rod.jpg',
      'assets/weeds/bolivian_coriander.jpg',
      'assets/weeds/bellyache_bush.jpg',
      'assets/weeds/parramatta_grass.jpg',
      'assets/weeds/westwood_pear.jpg',
      'assets/weeds/grader_grass.jpg',
      'assets/weeds/karroo_thorn.jpg',
      'assets/weeds/creeping_burrhead.jpg',
      'assets/weeds/oleander.jpg',
      'assets/weeds/flax-leaf_broom.jpg',
      'assets/weeds/creeping_inch_plant.jpg',
      'assets/weeds/hairy_cassia.jpg',
      'assets/weeds/cat&#039;s_claw_creeper.jpg',
      'assets/weeds/asthma_plant.jpg',
      'assets/weeds/greenleaf_desmodium.jpg',
      'assets/weeds/senegal_tea.jpg',
      'assets/weeds/ming_asparagus.jpg',
      'assets/weeds/urena_burr.jpg',
      'assets/weeds/blue_water_lily.jpg',
      'assets/weeds/brillantaisia.jpg',
      'assets/weeds/chinee_apple.jpg',
      'assets/weeds/indian_rubber_tree.jpg',
      'assets/weeds/slash_pine.jpg',
      'assets/weeds/ground_asparagus_fern.jpg',
      'assets/weeds/giant_rat&#039;s_tail_grass.jpg',
      'assets/weeds/corky_passion_vine.jpg',
      'assets/weeds/leucaena.jpg',
      'assets/weeds/chilean_needlegrass.jpg',
      'assets/weeds/broad-leaved_cumbungi.jpg',
      'assets/weeds/mile-a-minute.jpg',
      'assets/weeds/spiny_amaranth.jpg',
      'assets/weeds/spiny_rush.jpg',
      'assets/weeds/burr_medic.jpg',
      'assets/weeds/japanese_sunflower.jpg',
      'assets/weeds/hiptage.jpg',
      'assets/weeds/kudzu.jpg',
      'assets/weeds/spotted_spurge.jpg',
      'assets/weeds/blackberry.jpg',
      'assets/weeds/camphor_laurel.jpg',
      'assets/weeds/stinking_roger.jpg',
      'assets/weeds/peruvian_primrose.jpg',
      'assets/weeds/bitou_bush.jpg',
      'assets/weeds/creeping_phyllanthus.jpg',
      'assets/weeds/christ’s_thorn.jpg',
      'assets/weeds/balloon_cotton_bush.jpg',
      'assets/weeds/climbing_groundsel.jpg',
      'assets/weeds/foetid_cassia.jpg',
      'assets/weeds/red_sesbania.jpg',
      'assets/weeds/silver-leaved_cotoneaster.jpg',
      'assets/weeds/shoebutton_ardisia.jpg',
      'assets/weeds/floating_water_chestnut.jpg',
      'assets/weeds/moth_vine.jpg',
      'assets/weeds/purple_rubber_vine.jpg',
      'assets/weeds/rhodes_grass.jpg',
      'assets/weeds/ivy.jpg',
      'assets/weeds/stinking_passionflower.jpg',
      'assets/weeds/_night_jessamine.jpg',
      'assets/weeds/canna_lily.jpg',
      'assets/weeds/mist_flower.jpg',
      'assets/weeds/emilia.jpg',
      'assets/weeds/giant_parramatta_grass.jpg',
      'assets/weeds/morning_glory.jpg',
      'assets/weeds/koster’s_curse.jpg',
      'assets/weeds/lantana.jpg',
      'assets/weeds/common_coral_tree.jpg',
      'assets/weeds/duranta.jpg',
      'assets/weeds/northern_olive.jpg',
      'assets/weeds/water_hyacinth.jpg',
      'assets/weeds/stinkweed.jpg',
      'assets/weeds/blue_heliotrope.jpg',
      'assets/weeds/dalrymple_vigna.jpg',
      'assets/weeds/rubber_vine.jpg',
      'assets/weeds/billygoat_weed.jpg',
      'assets/weeds/prickly_pear.jpg',
      'assets/weeds/arum_lily.jpg',
      'assets/weeds/japanese_knotweed.jpg',
      'assets/weeds/yellow_bells.jpg',
      'assets/weeds/candy_leaf.jpg',
      'assets/weeds/coral_creeper.jpg',
      'assets/weeds/lance-leaved_rattlepod.jpg',
      'assets/weeds/radiata_pine.jpg',
      'assets/weeds/arsenic_bush.jpg',
      'assets/weeds/red-head_cotton_bush.jpg',
      'assets/weeds/golden_bamboo.jpg',
      'assets/weeds/tipuana.jpg',
      'assets/weeds/devil&#039;s_fig.jpg',
      'assets/weeds/ivy_gourd.jpg',
      'assets/weeds/parrot&#039;s_feather.jpg',
      'assets/weeds/mesquite_or_algarroba.jpg',
      'assets/weeds/yellow_burrhead.jpg',
      'assets/weeds/mexican_feathergrass.jpg',
      'assets/weeds/madeira_vine.jpg',
      'assets/weeds/leaf_cactus.jpg',
      'assets/weeds/larkdaisy.jpg',
      'assets/weeds/mullumbimby_couch.jpg',
      'assets/weeds/balsam_(busy_lizzie).jpg',
      'assets/weeds/pennywort.jpg',
      'assets/weeds/prickly_acacia.jpg',
      'assets/weeds/willows.jpg',
      'assets/weeds/broad-leaved_privet.jpg',
      'assets/weeds/golden_dodder.jpg',
      'assets/weeds/jewels_of_opar.jpg',
      'assets/weeds/anzac_tree_daisy.jpg',
      'assets/weeds/lagarosiphon.jpg',
      'assets/weeds/red_natal_grass.jpg',
      'assets/weeds/bridal_creeper.jpg',
      'assets/weeds/awabuki_sweet_viburnum.jpg',
      'assets/weeds/buffalo_grass.jpg',
      'assets/weeds/telegraph_weed.jpg',
      'assets/weeds/purpletop_rhodes_grass.jpg',
      'assets/weeds/loquat.jpg',
      'assets/weeds/ochna.jpg',
      'assets/weeds/sickle_pod.jpg',
      'assets/weeds/elastic_grass.jpg',
      'assets/weeds/american_rat&#039;s_tail_grass.jpg',
      'assets/weeds/bitter_weed.jpg',
      'assets/weeds/tree_tobacco.jpg',
      'assets/weeds/coral_berry.jpg',
      'assets/weeds/alligator_weed.jpg',
      'assets/weeds/cherry_guava.jpg',
      'assets/weeds/striped_inch_plant.jpg',
      'assets/weeds/red_cestrum.jpg',
      'assets/weeds/golden_shower_tree.jpg',
      'assets/weeds/chinese_foldwing.jpg',
      'assets/weeds/lions_ear.jpg',
      'assets/weeds/pongamia.jpg',
      'assets/weeds/parthenium_weed.jpg',
      'assets/weeds/siam_weed.jpg',
      'assets/weeds/awnless_barnyard.jpg',
      'assets/weeds/soursop.jpg',
      'assets/weeds/african_lovegrass.jpg',
      'assets/weeds/molasses_grass.jpg',
      'assets/weeds/laurel_clock_vine.jpg',
      'assets/weeds/bunny_ears.jpg',
      'assets/weeds/perennial_horse_gram.jpg',
      'assets/weeds/scotch_broom.jpg',
      'assets/weeds/yellow_ginger.jpg',
      'assets/weeds/silver-leaf_nightshade.jpg',
      'assets/weeds/black_bamboo.jpg',
      'assets/weeds/fishbone_fern.jpg',
      'assets/weeds/giant_sensitive_tree.jpg',
      'assets/weeds/indian_hawthorn.jpg',
      'assets/weeds/johnson_grass.jpg',
      'assets/weeds/whisky_grass.jpg',
      'assets/weeds/tropical_pickeral_weed.jpg',
      'assets/weeds/sagittaria.jpg',
      'assets/weeds/blue_billygoat_weed.jpg',
      'assets/weeds/annual_ragweed.jpg',
      'assets/weeds/mother_of_millions_hybrid.jpg',
      'assets/weeds/perennial_ragweed.jpg',
      'assets/weeds/yucca.jpg',
      'assets/weeds/jumping_cholla.jpg',
      'assets/weeds/creeping_indigo.jpg',
      'assets/weeds/bristly_star_bur.jpg',
      'assets/weeds/paspalum.jpg',
      'assets/weeds/trumpet_tree.jpg',
      'assets/weeds/nutgrass.jpg',
      'assets/weeds/crab&#039;s_eye_creeper.jpg',
      'assets/weeds/red_bauhinia.jpg',
      'assets/weeds/common_horsetail.jpg',
      'assets/weeds/coral_cactus.jpg',
      'assets/weeds/giant_devil&#039;s_fig.jpg',
      'assets/weeds/bindy_eye.jpg',
      'assets/weeds/tobacco_weed.jpg',
      'assets/weeds/prickly_poppy_or_mexican_poppy.jpg',
      'assets/weeds/crofton_weed.jpg',
      'assets/weeds/foxglove.jpg',
      'assets/weeds/silverleaf_desmodium_.jpg',
      'assets/weeds/balloon_vine.jpg',
      'assets/weeds/groundsel_bush.jpg',
      'assets/weeds/glush_weed.jpg',
      'assets/weeds/dark_blue_snakeweed.jpg',
      'assets/weeds/hybrid_mother-of-millions.jpg',
      'assets/weeds/bougainvillea.jpg',
      'assets/weeds/tropical_chickweed.jpg',
      'assets/weeds/ferny_and_red_azolla.jpg',
      'assets/weeds/cockspur_coral_tree.jpg',
      'assets/weeds/mysore_thorn.jpg',
      'assets/weeds/harrisia_cactus.jpg',
      'assets/weeds/quilpie_mesquite.jpg',
      'assets/weeds/snake_cactus.jpg',
      'assets/weeds/green_amaranth.jpg',
      'assets/weeds/painted_spurge.jpg',
      'assets/weeds/small_leaved_privet.jpg',
      'assets/weeds/crowsfoot_grass.jpg',
      'assets/weeds/anchored_water_hyacinth.jpg',
      'assets/weeds/dense_waterweed.jpg',
      'assets/weeds/chinese_tallow_tree.jpg',
      'assets/weeds/purple_joyweed.jpg',
      'assets/weeds/_indian_blue_grass.jpg',
      'assets/weeds/hophead_barleria.jpg',
      'assets/weeds/giant_sensitive_plant.jpg',
      'assets/weeds/african_fountain_grass.jpg',
      'assets/weeds/bridal_veil.jpg',
      'assets/weeds/african_tulip_tree_.jpg',
      'assets/weeds/tiger_pear.jpg',
      'assets/weeds/elephant_ear_vine.jpg',
      'assets/weeds/milk-flower_cotoneaster.jpg',
      'assets/weeds/gamba_grass.jpg',
      'assets/weeds/glory_lily.jpg',
      'assets/weeds/cabomba.jpg',
      'assets/weeds/kidney_leaf_mudplantain.jpg',
      'assets/weeds/brazilian_nightshade.jpg',
      'assets/weeds/jerusalem_thorn.jpg',
      'assets/weeds/yellow_oleander.jpg',
      'assets/weeds/velvety_tree_pear.jpg',
      'assets/weeds/cadaghi.jpg',
      'assets/weeds/madras_thorn.jpg',
      'assets/weeds/water_lettuce.jpg',
      'assets/weeds/african_boxthorn.jpg',
      'assets/weeds/golden_trumpet_tree.jpg',
      'assets/weeds/white_morning_glory.jpg',
      'assets/weeds/amazon_frogbit.jpg',
      'assets/weeds/pampas_grass.jpg',
      'assets/weeds/phasey_bean.jpg',
      'assets/weeds/blackberry_nightshade.jpg',
      'assets/weeds/wild_tobacco_tree.jpg',
      'assets/weeds/thorn_apples.jpg',
      'assets/weeds/bahia_grass.jpg',
      'assets/weeds/giant_reed.jpg',
      'assets/weeds/east_indian_hygrophila.jpg',
      'assets/weeds/cape_honeysuckle.jpg',
      'assets/weeds/witchweed.jpg',
      'assets/weeds/harungana.jpg',
      'assets/weeds/monkey&#039;s_comb.jpg',
      'assets/weeds/indian_mustard.jpg',
      'assets/weeds/garden_asparagus.jpg',
      'assets/weeds/hymenachne.jpg',
      'assets/weeds/candelabra_aloe.jpg',
      'assets/weeds/cudweed.jpg',
      'assets/weeds/guava.jpg',
      'assets/weeds/cape_spinach.jpg',
      'assets/weeds/taro.jpg',
      'assets/weeds/deadly_nightshade.jpg',
      'assets/weeds/tall_fleabane.jpg',
      'assets/weeds/water_soldiers.jpg',
      'assets/weeds/vasey_grass.jpg',
      'assets/weeds/devils_rope_pear.jpg',
      'assets/weeds/bathurst_burr.jpg',
      'assets/weeds/tree_of_heaven.jpg',
      'assets/weeds/water_mimosa.jpg',
      'assets/weeds/black-eyed_susan_.jpg',
      'assets/weeds/dyschoriste.jpg',
      'assets/weeds/hyssopleaf_sandmat.jpg',
      'assets/weeds/coffee.jpg',
      'assets/weeds/chinese_celtis.jpg',
      'assets/weeds/elephant_grass.jpg',
      'assets/weeds/white_ball_acacia.jpg',
      'assets/weeds/purple_succulent.jpg',
      'assets/weeds/flaxleaf_fleabane.jpg',
      'assets/weeds/athel_pine_.jpg',
      'assets/weeds/umbrella_sedge.jpg',
      'assets/weeds/cotoneaster.jpg',
      'assets/weeds/golden_rain_tree.jpg',
      'assets/weeds/ruellia.jpg',
      'assets/weeds/bunchy_sedge.jpg',
      'assets/weeds/white_oak.jpg',
      'assets/weeds/white_passionflower.jpg',
      'assets/weeds/para_grass.jpg',
      'assets/weeds/spiked_pepper.jpg',
      'assets/weeds/creeping_cinderella_weed.jpg',
      'assets/weeds/primrose_willow.jpg',
      'assets/weeds/broadleaved_pepper.jpg',
      'assets/weeds/salvinia.jpg',
      'assets/weeds/curry-leaf_tree.jpg',
      'assets/weeds/montpellier_broom.jpg',
      'assets/weeds/blue_thunbergia.jpg',
      'assets/weeds/hairy_commelina.jpg',
      'assets/weeds/signal_grass.jpg',
      'assets/weeds/cocos_palm.jpg',
      'assets/weeds/glycine.jpg',
      'assets/weeds/eurasian_water-milfoil.jpg',
      'assets/weeds/white_mulberry.jpg',
      'assets/weeds/parkinsonia.jpg',
      'assets/weeds/umbrella_tree.jpg',
      'assets/weeds/white_shrimp_plant.jpg',
      'assets/weeds/_wild_aster.jpg',
      'assets/weeds/boneseed.jpg',
      'assets/weeds/kikuyu.jpg',
      'assets/weeds/mother-in-law&#039;s_tongue.jpg',
      'assets/weeds/climbing_asparagus_fern.jpg',
      'assets/weeds/miconia.jpg',
      'assets/weeds/noogoora_burr.jpg',
      'assets/weeds/lavender_scallops.jpg',
      'assets/weeds/thickhead.jpg',
      'assets/weeds/tropical_soda_apple.jpg',
      'assets/weeds/badhara_bush.jpg',
      'assets/weeds/hemlock.jpg',
      'assets/weeds/hudson_pear.jpg',
    ];

    final BestMatch best = StringSimilarity.findBestMatch(speciesName, weeds);
    return weeds[best.bestMatchIndex];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 0,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      "http://cdn.onlinewebfonts.com/svg/img_299586.png",
                      width: 75,
                    ),
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Hamish Bultitude',
                        style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '4/10/2021',
                        style: TextStyle(fontSize: 25, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Spacer()
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Achievements',
              style: TextStyle(fontSize: 23, color: Colors.black),
              textAlign: TextAlign.start,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Achievement("Find 10 Low Severity", "7/10/2021", "lowsev_1"),
                  Achievement("Find 20 Low Severity", "20/10/2021", "lowsev_2"),
                  Achievement("Find 10 Medium Severity", "10/10/2021", "medsev_1"),
                  Achievement("Find 10 Medium Severity", "7/10", "none"),
                  Achievement("Find Plants in 5 Unique Councils", "1/11/2021", "location_1"),
                  Achievement("Find Plants in 10 Unique Councils", "6/10", "none"),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Reports',
              style: TextStyle(fontSize: 23, color: Colors.black),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 1,
            child: FutureBuilder(
                future: loaded,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                        child: SmartRefresher(
                      enablePullDown: true,
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      child: new ListView.builder(
                          itemCount: organisedReports.keys.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Card(
                                elevation: 0,
                                shape: new RoundedRectangleBorder(
                                    // side: new BorderSide(color: Colors.black, width: 2.0),
                                    borderRadius: BorderRadius.circular(4.0)),
                                child: Column(
                                  children: [
                                    Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          bestPlantImage(organisedReports.keys.elementAt(index)),
                                          height: 75,
                                        ),
                                      ),
                                      Text(
                                        organisedReports.keys.elementAt(index),
                                        style:
                                            TextStyle(fontSize: 18, color: Colors.black, fontStyle: FontStyle.italic),
                                        textAlign: TextAlign.start,
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                          organisedReports[organisedReports.keys.elementAt(index)]!.length.toString(),
                                          style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: "mono"),
                                          textAlign: TextAlign.start,
                                        ),
                                      )
                                    ]),
                                    Column(
                                      children:
                                          organisedReports[organisedReports.keys.elementAt(index)]!.map<Widget>((item) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                                          child: ReportCard(item),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ));
                          }),
                    ));
                  } else {
                    return Align(alignment: Alignment.center, child: CircularProgressIndicator());
                  }
                }),
          )
        ],
      ),
    );
  }
}

class ReportCard extends StatefulWidget {
  Report report;

  ReportCard(this.report);

  @override
  _ReportCardState createState() => new _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportPage(report: widget.report)),
        );
      },
      child: new Container(
          height: 120,
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 15.0, 0, 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.report.id.timestamp.day}/${widget.report.id.timestamp.month}/${widget.report.id.timestamp.year}",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${widget.report.id.timestamp.hour}:${widget.report.id.timestamp.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          Status(status: widget.report.status)
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 100, maxWidth: 100),
                        child: ClipRRect(child: renderImage(), borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),
            ),
          )),
    );
  }

  Widget renderImage() {
    if (widget.report.photoLocations.isNotEmpty) {
      return Image.network(getImageURL(widget.report.photoLocations.first).toString());
    } else {
      return Image.asset("assets/badges/none.jpg");
    }
  }
}

class Status extends StatelessWidget {
  const Status({
    Key? key,
    required this.status,
  }) : super(key: key);

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case "closed":
        color = Colors.redAccent;
        break;
      case "open":
        color = Colors.green;
        break;
      default:
        color = Colors.green;
    }
    return Center(
      child: Container(
        child: Card(
          elevation: 0,
          shape: new RoundedRectangleBorder(
              side: new BorderSide(color: color, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon(
                //   Icons.circle,
                //   color: color,
                //   size: 15,
                // ),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(fontSize: 15, color: color),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Achievement extends StatelessWidget {
  Achievement(this.title, this.date, this.badge_name);

  String title;
  String date;
  String badge_name;

  // const Achievement({
  //   Key? key,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        // color: Colors.purple[600],
        child: Card(
          elevation: 5,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                child: Image.asset(
                  "assets/badges/$badge_name.jpg",
                  width: 65,
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (date != "")
                      Text(
                        "$date",
                        textAlign: TextAlign.center,
                      )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
