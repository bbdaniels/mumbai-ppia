 gen treat = pxh == 1 & wave > 0
      lab var treat "PPIA in Round 2"

      save "${directory}/data/deidentified/demo.dta"

    // Global
    areg re_4 treat pxh ///
      i.wave i.sample##i.case ///
      if  case < 7 ///
      , a(cp_4) cl(cp_7)

      forest areg ///
        (dr_1 dr_4 re_1 re_3 re_4) ///
        (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
      if case < 7 ///
      , t(treat) c(pxh i.wave i.sample##i.case) ///
        a(cp_4) cl(cp_7) b bh

      // Alt versions
        // No sample-case interaction
        areg re_4 treat pxh i.wave ///
          i.case ///
          if case < 7 ///
          , a(cp_4) cl(cp_7)

        // Case-wave interaction
        areg re_4 treat pxh i.wave ///
          i.wave##i.case i.sample##i.case ///
          if case < 7 ///
          , a(cp_4) cl(cp_7)

        // Facility clustering
        areg re_4 treat pxh i.wave ///
          i.sample##i.case ///
          if case < 7 ///
          , a(cp_4) cl(cp_4)

        // No FE
        reg re_4 treat pxh i.wave ///
          i.sample##i.case ///
          if case < 7 ///
          , cl(cp_7)

    // Diff-diff
    areg re_4 treat pxh i.wave ///
      i.sample##i.case ///
      if wave < 2 & case < 7 ///
      , a(cp_4) cl(cp_7)

      forest areg ///
        (dr_1 dr_4 re_1 re_3 re_4) ///
        (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
      if wave < 2 & case < 7 ///
      , t(treat) c(pxh wave i.wave i.sample##i.case) ///
        a(cp_4) cl(cp_7)

      // Alt versions
        // No sample-case interaction
        areg re_4 treat pxh i.wave ///
          i.case ///
          if wave < 2 & case < 7 ///
          , a(cp_4) cl(cp_7)

        // Case-wave interaction
        areg re_4 treat pxh i.wave ///
          i.wave##i.case i.sample##i.case ///
          if wave < 2 & case < 7 ///
          , a(cp_4) cl(cp_7)

        // Facility clustering
        areg re_4 treat pxh i.wave ///
          i.sample##i.case ///
          if wave < 2 & case < 7 ///
          , a(cp_4) cl(cp_4)

        // No FE
        reg re_4 treat pxh i.wave ///
          i.sample##i.case ///
          if wave < 2 & case < 7 ///
          , cl(cp_7)

        // Provider FE
        areg re_4 treat pxh i.wave ///
          i.sample##i.case ///
          if wave < 2 & case < 7 ///
          , a(cp_7) cl(cp_7)
