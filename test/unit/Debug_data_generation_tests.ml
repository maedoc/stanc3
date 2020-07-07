open Frontend
open Core_kernel
open Debug_data_generation

let%expect_test "whole program data generation check" =
  let open Parse in
  let ast =
    parse_string Parser.Incremental.program
      {|       data {
                  int<lower=7> K;
                  int<lower=1> D;
                  int<lower=0> N;
                  int<lower=0,upper=1> y[N,D];
                  vector[K] x[N];
                    }
      |}
  in
  let ast =
    Option.value_exn
      (Result.ok
         (Semantic_check.semantic_check_program
            (Option.value_exn (Result.ok ast))))
  in
  let str = print_data_prog ast in
  print_s [%sexp (str : string)] ;
  [%expect
    {|
       "{\
      \n\"K\": 11, \"D\": 3, \"N\": 1, \"y\": [[1, 1, 0]],\
      \n\"x\":\
      \n  [[5.8799711085519224, 4.1465170437036338, 3.543689144366625,\
      \n     6.0288479433993629, 3.604405750889411, 4.0759938356540726,\
      \n     2.56799363086151, 3.3282621325833865, 2.7103944900448411,\
      \n     5.2015419032442969, 4.25312636944623]]\
      \n}" |}]

let%expect_test "whole program data generation check" =
  let open Parse in
  let ast =
    parse_string Parser.Incremental.program
      {|       data {
                    int x[3, 4];
                    int y[5, 2, 4];
                    matrix[3, 4] z;
                    vector[3] w;
                    vector[3] p[4];
                }
      |}
  in
  let ast =
    Option.value_exn
      (Result.ok
         (Semantic_check.semantic_check_program
            (Option.value_exn (Result.ok ast))))
  in
  let str = print_data_prog ast in
  print_s [%sexp (str : string)] ;
  [%expect
    {|
       "{\
      \n\"x\": [[2, 3, 5, 6], [5, 4, 5, 5], [2, 5, 4, 6]],\
      \n\"y\":\
      \n  [[[3, 2, 2, 3], [5, 5, 6, 2]], [[6, 2, 2, 5], [5, 4, 6, 4]],\
      \n    [[5, 2, 6, 5], [3, 5, 2, 2]], [[3, 4, 2, 5], [6, 3, 4, 2]],\
      \n    [[3, 2, 3, 2], [5, 3, 2, 3]]],\
      \n\"z\":\
      \n  [[4.1949090422787174, 4.1512076186352216, 6.97070615398329,\
      \n     3.7293083759369448],\
      \n    [4.869813970717308, 3.8281495864625956, 2.3295401414257744,\
      \n      4.0319385317762162],\
      \n    [5.7213345511646363, 3.5720962307677091, 3.2425011320285027,\
      \n      2.6451502425447266]],\
      \n\"w\": [4.7922353997475788, 4.9461191671001892, 6.8138349711922652],\
      \n\"p\":\
      \n  [[3.19883563012539, 6.4287706833617158, 6.5986584016153875],\
      \n    [4.6676412390878905, 4.2138065257931459, 5.7759384905058795],\
      \n    [4.0434169569431706, 5.2448759493135153, 2.0095894885098069],\
      \n    [3.8556222147542085, 3.226595023801782, 2.292622453020976]]\
      \n}" |}]

let%expect_test "whole program data generation check" =
  let open Parse in
  let ast =
    parse_string Parser.Incremental.program
      {|       data {
                  int<lower=2, upper=4> K;
                  int<lower=K, upper=K> D;
                  vector[K - 1] x;
                  vector[K * D] y;
                  vector[K ? D : K] z;
                  vector[K ? D : K] w[(D + 2 == K) + 3];
                }
      |}
  in
  let ast =
    Option.value_exn
      (Result.ok
         (Semantic_check.semantic_check_program
            (Option.value_exn (Result.ok ast))))
  in
  let str = print_data_prog ast in
  print_s [%sexp (str : string)] ;
  [%expect
    {|
       "{\
      \n\"K\": 2, \"D\": 2, \"x\": [6.8017664359959342],\
      \n\"y\":\
      \n  [2.7103944900448411, 5.2015419032442969, 4.25312636944623,\
      \n    4.8441784126802627], \"z\": [2.56799363086151, 3.3282621325833865],\
      \n\"w\":\
      \n  [[5.8799711085519224, 4.1465170437036338],\
      \n    [3.543689144366625, 6.0288479433993629],\
      \n    [3.604405750889411, 4.0759938356540726]]\
      \n}" |}]

let%expect_test "whole program data generation check" =
  let open Parse in
  let ast =
    parse_string Parser.Incremental.program
      {|
        data {
          corr_matrix[5] d;
          cov_matrix[4] e;
          cholesky_factor_cov[4] f;
          cholesky_factor_corr[4] g;
          unit_vector[4] h;
          simplex[12] i;
          ordered[2] j;
          positive_ordered[4] k;
          cholesky_factor_cov[5, 4] l;
        }
      |}
  in
  let ast =
    Option.value_exn
      (Result.ok
         (Semantic_check.semantic_check_program
            (Option.value_exn (Result.ok ast))))
  in
  let str = print_data_prog ast in
  print_s [%sexp (str : string)] ;
  [%expect
    {|
       "{\
      \n\"d\":\
      \n  [[1., 0., 0., 0., 0.], [0., 1., 0., 0., 0.], [0., 0., 1., 0., 0.],\
      \n    [0., 0., 0., 1., 0.], [0., 0., 0., 0., 1.]],\
      \n\"e\":\
      \n  [[4.1756020752914917, 3.4039323294515285, 2.1020272741214319,\
      \n     4.9792951803589354],\
      \n    [3.4039323294515285, 4.0797536231406983, 2.2422902438616941,\
      \n      4.3471534490929464],\
      \n    [2.1020272741214319, 2.2422902438616941, 2.0546284715631029,\
      \n      2.4724763293584981],\
      \n    [4.9792951803589354, 4.3471534490929464, 2.4724763293584981,\
      \n      6.5571126103807105]],\
      \n\"f\": [[1., 0., 0., 0.], [0., 1., 0., 0.], [0., 0., 1., 0.], [0., 0., 0., 1.]],\
      \n\"g\": [[1., 0., 0., 0.], [0., 1., 0., 0.], [0., 0., 1., 0.], [0., 0., 0., 1.]],\
      \n\"h\":\
      \n  [0.32738564693053218, 0.64605344907040807, 0.32190629626707262,\
      \n    0.60976217950256839],\
      \n\"i\":\
      \n  [0.014150290414827583, 0.087250433908635211, 0.15979226203485844,\
      \n    0.067505033314521068, 0.053352383059881194, 0.027702431799983208,\
      \n    0.11035993031063894, 0.17243721576282997, 0.071272220935429953,\
      \n    0.14488314058385138, 0.084420677590089421, 0.0068739802844535926],\
      \n\"j\": [1., -0.43041856659611644],\
      \n\"k\": [1., 0.76803086048591518, 0.32444831863445711, 0.072056127427604852],\
      \n\"l\":\
      \n  [[1., 0., 0., 0.], [0., 1., 0., 0.], [0., 0., 1., 0.], [0., 0., 0., 1.],\
      \n    [0., 0., 0., 0.]]\
      \n}" |}]

let%expect_test "whole program data generation check" =
  let open Parse in
  let ast =
    parse_string Parser.Incremental.program
      {|
        data {
          int<lower=0> N;
          int<lower=0> M;
          int<lower=0, upper=N * M> K;
          int<upper=N> d_int_1d_ar[N];
          int<upper=N> d_int_3d_ar[N, M, K];
          real<lower=-2.0, upper=2.0> J;
          real d_real_1d_ar[N];
          real d_real_3d_ar[N, M, K];
          vector[N] d_vec;
          vector[N] d_1d_vec[N];
          vector[N] d_3d_vec[N, M, K];
          row_vector[N] d_row_vec;
          row_vector[N] d_1d_row_vec[N];
          row_vector[N] d_3d_row_vec[N, M, K];
          matrix<lower=0, upper=1>[2, 3] d_ar_mat[4, 5];
          simplex[N] d_simplex;
          simplex[N] d_1d_simplex[N];
          simplex[N] d_3d_simplex[N, M, K];
          cholesky_factor_cov[5, 4] d_cfcov_54;
          cholesky_factor_cov[3] d_cfcov_33;
          cholesky_factor_cov[3] d_cfcov_33_ar[K];
        }
      |}
  in
  let ast =
    Option.value_exn
      (Result.ok
         (Semantic_check.semantic_check_program
            (Option.value_exn (Result.ok ast))))
  in
  let str = print_data_prog ast in
  print_s [%sexp (str : string)] ;
  [%expect
    {|
       "{\
      \n\"N\": 3, \"M\": 1, \"K\": 2, \"d_int_1d_ar\": [2, 2, -1],\
      \n\"d_int_3d_ar\": [[[-1, 0]], [[2, 3]], [[2, 1]]], \"J\": -0.937390293933291,\
      \n\"d_real_1d_ar\": [3.604405750889411, 4.0759938356540726, 2.56799363086151],\
      \n\"d_real_3d_ar\":\
      \n  [[[2.2826025797056464, 4.521098476935741]],\
      \n    [[5.8799711085519224, 4.1465170437036338]],\
      \n    [[3.543689144366625, 6.0288479433993629]]],\
      \n\"d_vec\": [5.508750812969728, 3.7482903006745985, 5.3116509882058738],\
      \n\"d_1d_vec\":\
      \n  [[3.2425011320285027, 2.6451502425447266, 4.5701258402582194],\
      \n    [6.0158175418085342, 3.6598286733521297, 5.3741223139973622],\
      \n    [3.9660375311552749, 2.1600852257225154, 3.7780489469949972]],\
      \n\"d_3d_vec\":\
      \n  [[[[5.2448759493135153, 2.0095894885098069, 3.8556222147542085],\
      \n      [3.226595023801782, 2.292622453020976, 4.7922353997475788]]],\
      \n    [[[4.9461191671001892, 6.8138349711922652, 4.1949090422787174],\
      \n       [4.1512076186352216, 6.97070615398329, 3.7293083759369448]]],\
      \n    [[[4.869813970717308, 3.8281495864625956, 2.3295401414257744],\
      \n       [4.0319385317762162, 5.7213345511646363, 3.5720962307677091]]]],\
      \n\"d_row_vec\": [4.2138065257931459, 5.7759384905058795, 4.0434169569431706],\
      \n\"d_1d_row_vec\":\
      \n  [[5.5315257534514712, 2.1318346935923507, 2.4903795562578557],\
      \n    [2.0298667610240964, 2.5869872307079236, 3.19883563012539],\
      \n    [6.4287706833617158, 6.5986584016153875, 4.6676412390878905]],\
      \n\"d_3d_row_vec\":\
      \n  [[[[5.8259738592178358, 6.29275143528753, 5.7992229887995883],\
      \n      [6.4835819351872654, 6.2480788401756451, 2.7137240155194529]]],\
      \n    [[[5.6252338866513316, 3.2151318313470769, 4.3293598111485032],\
      \n       [6.8340525891748189, 4.5064008029760334, 5.406294923615655]]],\
      \n    [[[6.2243138037125068, 6.4536316336809891, 2.3777024486238973],\
      \n       [4.9283096565285138, 3.3969401849295595, 6.0608327679881207]]]],\
      \n\"d_ar_mat\":\
      \n  [[[[0.30265828158408009, 0.53857837713598755, 0.99435438254623754],\
      \n      [0.11800610357991351, 0.86493323130460953, 0.70138904116412959]],\
      \n     [[0.85689633306737, 0.70234904561486411, 0.34655572443742166],\
      \n       [0.11214741225685448, 0.56198012898460514, 0.80739555544465147]],\
      \n     [[0.67800624128286135, 0.187060423355116, 0.65864668749480892],\
      \n       [0.7609047403379835, 0.53296791805267507, 0.71061143479186961]],\
      \n     [[0.70107413958330755, 0.27600029727304715, 0.56797857787417749],\
      \n       [0.18822532999887831, 0.90928692941997247, 0.031145119767167891]],\
      \n     [[0.4442483267716999, 0.11839458744816142, 0.37368848174295793],\
      \n       [0.42241174496887768, 0.78382782365681281, 0.32234368458918788]]],\
      \n    [[[0.71651676085087923, 0.62502894666644682, 0.85124674765564845],\
      \n       [0.20495821973392631, 0.73738252703807183, 0.29201824556948469]],\
      \n      [[0.23083019388406939, 0.87516028181059635, 0.37399667670291026],\
      \n        [0.97022141344482138, 0.41461589756593475, 0.84919075650439724]],\
      \n      [[0.88571739200345234, 0.15572378717971833, 0.612115128160238],\
      \n        [0.94372088555262923, 0.65802867310905055, 0.32648564309712513]],\
      \n      [[0.96871518974459825, 0.28083725052478087, 0.760763820464],\
      \n        [0.73727587916715787, 0.28217720706625904, 0.42912560381062059]],\
      \n      [[0.10875698401043367, 0.36618179036051896, 0.46310136757192755],\
      \n        [0.90195439170705294, 0.0645661949334827, 0.91994370419748739]]],\
      \n    [[[0.53312849666186346, 0.42006156138308287, 0.80682474661040526],\
      \n       [0.90178256755944575, 0.1331771098716274, 0.85453819372996653]],\
      \n      [[0.70416418983239637, 0.78991889014591155, 0.64874258612805491],\
      \n        [0.91101702970394483, 0.97374370343899963, 0.36659486283528481]],\
      \n      [[0.67563924241031859, 0.5801137402153288, 0.90158697893162376],\
      \n        [0.027137609222934244, 0.63969386779910664, 0.77108493814941892]],\
      \n      [[0.51405972722094162, 0.49822874401216449, 0.35780805786467229],\
      \n        [0.6497000557737248, 0.41035818879220193, 0.13069440403330407]],\
      \n      [[0.43793668913684858, 0.13622771624317104, 0.015030294346858163],\
      \n        [0.89518896165033413, 0.7923933751954082, 0.34067444210810638]]],\
      \n    [[[0.55973460502049532, 0.44445381850779669, 0.51080157622790656],\
      \n       [0.16357954010812856, 0.17576132217686963, 0.78663225739768683]],\
      \n      [[0.29767813861434933, 0.0331482211644266, 0.22407621955437815],\
      \n        [0.79459953975728093, 0.71924027388196421, 0.20559486843854785]],\
      \n      [[0.692956694659322, 0.581578803128905, 0.9014260551054567],\
      \n        [0.78390466305359885, 0.975395038570636, 0.57821828544361364]],\
      \n      [[0.395832644895654, 0.90623281519386112, 0.90299905969887218],\
      \n        [0.97871332361306373, 0.67108049948136128, 0.31270201687960314]],\
      \n      [[0.97429570147644506, 0.9255170309180637, 0.10640786283706954],\
      \n        [0.075435907403433713, 0.77523119897494908, 0.19010828624332626]]]],\
      \n\"d_simplex\": [0.46103541990514807, 0.23166736894495787, 0.30729721114989411],\
      \n\"d_1d_simplex\":\
      \n  [[0.32369749707698914, 0.41903611877747748, 0.25726638414553332],\
      \n    [0.022643830391066874, 0.50671628568629334, 0.47063988392263983],\
      \n    [0.13209844170749788, 0.77945710856527861, 0.088444449727223429]],\
      \n\"d_3d_simplex\":\
      \n  [[[[0.039932594588089045, 0.880151205772848, 0.079916199639062852],\
      \n      [0.33471911233610474, 0.20838925358574761, 0.4568916340781477]]],\
      \n    [[[0.46120582283716416, 0.17504619363987861, 0.36374798352295723],\
      \n       [0.10950731909322838, 0.15014668749639, 0.74034599341038165]]],\
      \n    [[[0.18067281549257905, 0.47131712267841813, 0.34801006182900285],\
      \n       [0.69668936436186313, 0.276503877179793, 0.026806758458343793]]]],\
      \n\"d_cfcov_54\":\
      \n  [[1., 0., 0., 0.], [0., 1., 0., 0.], [0., 0., 1., 0.], [0., 0., 0., 1.],\
      \n    [0., 0., 0., 0.]],\
      \n\"d_cfcov_33\": [[1., 0., 0.], [0., 1., 0.], [0., 0., 1.]],\
      \n\"d_cfcov_33_ar\":\
      \n  [[[1., 0., 0.], [0., 1., 0.], [0., 0., 1.]],\
      \n    [[1., 0., 0.], [0., 1., 0.], [0., 0., 1.]]]\
      \n}" |}]

let%expect_test "whole program data generation check" =
  let open Parse in
  let ast =
    parse_string Parser.Incremental.program
      {|
      data {
        int<lower = 0> K;                     // players
        int<lower = 0> N;                     // games
        int<lower=1, upper = K> player1[N];   // player 1 for game n
        int<lower=1, upper = K> player0[N];   // player 0 for game n
        int<lower = 0, upper = 1> y[N];       // winner for game n
      }
      |}
  in
  let ast =
    Option.value_exn
      (Result.ok
         (Semantic_check.semantic_check_program
            (Option.value_exn (Result.ok ast))))
  in
  let str = print_data_prog ast in
  print_s [%sexp (str : string)] ;
  [%expect
    {|
       "{ \"K\": 3, \"N\": 1, \"player1\": [2], \"player0\": [1], \"y\": [1]\
      \n}" |}]
