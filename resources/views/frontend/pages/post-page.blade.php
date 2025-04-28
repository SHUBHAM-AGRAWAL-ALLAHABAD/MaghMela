<!-- @extends('frontend.layout.app') -->
@extends('layouts.app')

@section('content')
    @include('frontend.components.post.article')
    <!-- @include('frontend.components.post.raleted') -->
    @include('frontend.components.post.alert')
    @include('frontend.components.post.modal')
@endsection

