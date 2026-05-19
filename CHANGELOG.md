# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-05-19

### Changed

- Updated Chart annotations for OCI repositories.
- Synced fork with upstream `ray-project/kuberay` master (through `v1.6.1`).
- Synced CRDs in `helm/kuberay/crds/` with upstream (`helm-chart/kuberay-operator/crds/`), including the new `ray.io_raycronjobs.yaml`.
- Refreshed templates and `values.yaml` in `helm/kuberay/` from the upstream-tracking `helm-chart/kuberay-operator/`. Brings missing RBAC for `secrets`, `pods/resize`, `services/proxy`, leases, and the new `ray.io/v1alpha1.RayCronJob` editor/viewer ClusterRoles. Preserves the GS `application.giantswarm.io/team` label injection.

### Fixed

- Pinned the operator image tag in `helm/kuberay/values.yaml` to `v1.6.1` (was `nightly`). The moving `nightly` tag had drifted past the chart-shipped RBAC, leaving the operator running but unable to reconcile.
- Added the `io.giantswarm.application.audience` / `io.giantswarm.application.team` OCI annotations to `helm/kuberay/Chart.yaml` (the actual published chart). Previously they were only on `helm-chart/kuberay-operator/Chart.yaml`, which is not the chart shipped by the CircleCI pipeline.

## [1.0.0] - 2025-10-07

### Added

- Create first GS artifact.

[Unreleased]: https://github.com/giantswarm/kuberay/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/giantswarm/kuberay/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/giantswarm/kuberay/releases/tag/v1.0.0

