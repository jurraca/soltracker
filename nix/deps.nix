{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    basefiftyeight = buildMix rec {
      name = "basefiftyeight";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0yl3h59sca8hv6r40kr8baxfbla8mllw0a46x48wfa4m898za4mg";
      };

      beamDeps = [];
    };

    connection = buildMix rec {
      name = "connection";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1746n8ba11amp1xhwzp38yfii2h051za8ndxlwdykyqqljq1wb3j";
      };

      beamDeps = [];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "000zl3y8xw1bhgj47mm4qznyqm24iiflxmlak8d7i6arxhkd4dpa";
      };

      beamDeps = [ connection telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xzm8hfhn8q02rmg8cpgs68n5jz61wvqg7bxww9i1a6yanf6wril";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.7.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0f463fw0mydnk7vsy7rinsly85lpbn3f3nylzx66b7j7zhwmnvnk";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.7.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "108w80dax7h043x079gkycsbmc5k3a4ig1n8lnmn8bz95hpa6hib";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    ed25519 = buildMix rec {
      name = "ed25519";
      version = "1.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1r0ja02binh7zs9sz8mbzylq8l28fwvwmjkd6iv3a798y4wx3g6d";
      };

      beamDeps = [];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0y91s7q8zlfqd037c1mhqdhrvrf60l4ax7lzya1y33h5y3sji8hq";
      };

      beamDeps = [ decimal ];
    };

    mime = buildMix rec {
      name = "mime";
      version = "1.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19qrpnmaf3w8bblvkv6z5g82hzd10rhc7bqxvqyi88c37xhsi89i";
      };

      beamDeps = [];
    };

    nimble_options = buildMix rec {
      name = "nimble_options";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0bd0pi3sij9vxhiilv25x6n3jls75g3b38rljvm1x896ycd1qw76";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.15.13";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wbhmz93q74xbxcgnhcp3j3jhzxnzwkjlqwmd9fgxzkwm7hpdyrz";
      };

      beamDeps = [ connection db_connection decimal jason ];
    };

    rustler = buildMix rec {
      name = "rustler";
      version = "0.22.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "062icn27xxssaqs30ngg6c4y2wchbass5y8acwnhmml63qa2kcan";
      };

      beamDeps = [ jason toml ];
    };

    solana = buildMix rec {
      name = "solana";
      version = "0.1.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "10cbkijkw99i5mq9jb9xvv50c99hbxcfq71v8m8y7lkdqsfwvb9g";
      };

      beamDeps = [ basefiftyeight ed25519 jason nimble_options tesla ];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0yn5mr83hrx0dslsqxmfr5zf0a65hdak6926zd72i85lb7x0kg3k";
      };

      beamDeps = [];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11h3fnsmkwjbhvs70rjqljfzinvsr4hg6c99yx56ckdzcjv5nxg0";
      };

      beamDeps = [ jason mime telemetry ];
    };

    toml = buildMix rec {
      name = "toml";
      version = "0.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01qafnclxnb9dd650h8i020p5ig70l78rlgs2p811d8zyyzdmqzi";
      };

      beamDeps = [];
    };

    websockex = buildMix rec {
      name = "websockex";
      version = "0.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1r2kmi2pcmdzvgbd08ci9avy0g5p2lhx80jn736a98w55c3ygwlm";
      };

      beamDeps = [];
    };
  };
in self

