# Patches

`scripts/apply-patches.sh` applies Kernarium's lineage-24 routes (`android/lineage-24/patches/projects.tsv`) to the GrapheneOS tree.

- `skip.txt`: routes not applied.
- `pNNNN/`: a rebased series for a route (`series.tsv` + `*.patch`), used instead of Kernarium's.
