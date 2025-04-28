{{-- resources/views/frontend/components/home/article.blade.php --}}
@extends('frontend.layout.app')

@section('content')
  <div class="container my-5">
    <div class="row justify-content-center">

      {{-- Package Card --}}
      <div class="col-md-6">
        <div class="card shadow-sm border-0">
          {{-- ऊपर की इमेज --}}
          <img 
            src="{{ asset($post->image) }}" 
            class="card-img-top" 
            alt="{{ $post->destination }} image"
          >

          {{-- कार्ड बॉडी --}}
          <div class="card-body text-center">
            {{-- Destination नाम --}}
            <h2 class="card-title fw-bold mb-3">{{ $post->destination }}</h2>

            {{-- 2 लाइन का डिस्क्रिप्शन --}}
            <p class="card-text text-muted mb-4">
              {{ Str::limit($post->description, 120) }}
            </p>
          </div>
        </div>
      </div>
      {{-- /Package Card --}}

    </div>
  </div>

  {{-- हमेशा नीचे दिखने वाला Book Now बटन --}}
  <a 
    href="{{ $post->booking_url }}" 
    target="_blank"
    class="btn btn-warning btn-lg position-fixed bottom-0 start-50 translate-middle-x mb-4"
    style="z-index: 1050; width: 200px;"
  >
    Book Now
  </a>
@endsection
