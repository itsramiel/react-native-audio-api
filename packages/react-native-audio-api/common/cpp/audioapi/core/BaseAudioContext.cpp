#include <audioapi/core/BaseAudioContext.h>
#include <audioapi/core/analysis/AnalyserNode.h>
#include <audioapi/core/destinations/AudioDestinationNode.h>
#include <audioapi/core/effects/BiquadFilterNode.h>
#include <audioapi/core/effects/GainNode.h>
#include <audioapi/core/effects/StereoPannerNode.h>
#include <audioapi/core/sources/AudioBuffer.h>
#include <audioapi/core/sources/AudioBufferQueueSourceNode.h>
#include <audioapi/core/sources/AudioBufferSourceNode.h>
#include <audioapi/core/sources/OscillatorNode.h>
#include <audioapi/core/utils/AudioDecoder.h>
#include <audioapi/core/utils/AudioNodeManager.h>
#include <audioapi/events/AudioEventHandlerRegistry.h>
#include <audioapi/utils/AudioArray.h>
#include <audioapi/utils/AudioBus.h>
#include <audioapi/utils/CircularAudioArray.h>

namespace audioapi {

BaseAudioContext::BaseAudioContext(
    const std::shared_ptr<AudioEventHandlerRegistry>
        &audioEventHandlerRegistry) {
  nodeManager_ = std::make_shared<AudioNodeManager>();
  destination_ = std::make_shared<AudioDestinationNode>(this);

  audioEventHandlerRegistry_ = audioEventHandlerRegistry;
}

std::string BaseAudioContext::getState() {
  return BaseAudioContext::toString(state_);
}

float BaseAudioContext::getSampleRate() const {
  return sampleRate_;
}

std::size_t BaseAudioContext::getCurrentSampleFrame() const {
  assert(destination_ != nullptr);
  return destination_->getCurrentSampleFrame();
}

double BaseAudioContext::getCurrentTime() const {
  assert(destination_ != nullptr);
  return destination_->getCurrentTime();
}

std::shared_ptr<AudioDestinationNode> BaseAudioContext::getDestination() {
  return destination_;
}

std::shared_ptr<OscillatorNode> BaseAudioContext::createOscillator() {
  auto oscillator = std::make_shared<OscillatorNode>(this);
  nodeManager_->addSourceNode(oscillator);
  return oscillator;
}

std::shared_ptr<GainNode> BaseAudioContext::createGain() {
  auto gain = std::make_shared<GainNode>(this);
  nodeManager_->addProcessingNode(gain);
  return gain;
}

std::shared_ptr<StereoPannerNode> BaseAudioContext::createStereoPanner() {
  auto stereoPanner = std::make_shared<StereoPannerNode>(this);
  nodeManager_->addProcessingNode(stereoPanner);
  return stereoPanner;
}

std::shared_ptr<BiquadFilterNode> BaseAudioContext::createBiquadFilter() {
  auto biquadFilter = std::make_shared<BiquadFilterNode>(this);
  nodeManager_->addProcessingNode(biquadFilter);
  return biquadFilter;
}

std::shared_ptr<AudioBufferSourceNode> BaseAudioContext::createBufferSource(
    bool pitchCorrection) {
  auto bufferSource =
      std::make_shared<AudioBufferSourceNode>(this, pitchCorrection);
  nodeManager_->addSourceNode(bufferSource);
  return bufferSource;
}

std::shared_ptr<AudioBufferQueueSourceNode>
BaseAudioContext::createBufferQueueSource() {
  auto bufferSource = std::make_shared<AudioBufferQueueSourceNode>(this);
  nodeManager_->addSourceNode(bufferSource);
  return bufferSource;
}

std::shared_ptr<AudioBuffer> BaseAudioContext::createBuffer(
    int numberOfChannels,
    size_t length,
    float sampleRate) {
  return std::make_shared<AudioBuffer>(numberOfChannels, length, sampleRate);
}

std::shared_ptr<PeriodicWave> BaseAudioContext::createPeriodicWave(
    const std::vector<std::complex<float>> &complexData,
    bool disableNormalization,
    int length) {
  return std::make_shared<PeriodicWave>(
      sampleRate_, complexData, length, disableNormalization);
}

std::shared_ptr<AnalyserNode> BaseAudioContext::createAnalyser() {
  auto analyser = std::make_shared<AnalyserNode>(this);
  nodeManager_->addProcessingNode(analyser);
  return analyser;
}

std::shared_ptr<AudioBuffer> BaseAudioContext::decodeAudioDataSource(
    const std::string &path) {
  auto audioBus = audioDecoder_->decodeWithFilePath(path);

  if (!audioBus) {
    return nullptr;
  }

  return std::make_shared<AudioBuffer>(audioBus);
}

std::shared_ptr<AudioBuffer> BaseAudioContext::decodeAudioData(
    const void *data,
    size_t size) {
  auto audioBus = audioDecoder_->decodeWithMemoryBlock(data, size);

  if (!audioBus) {
    return nullptr;
  }

  return std::make_shared<AudioBuffer>(audioBus);
}

std::shared_ptr<AudioBuffer> BaseAudioContext::decodeWithPCMInBase64(
    const std::string &data) {
  auto audioBus = audioDecoder_->decodeWithPCMInBase64(data);

  if (!audioBus) {
    return nullptr;
  }

  return std::make_shared<AudioBuffer>(audioBus);
}

AudioNodeManager *BaseAudioContext::getNodeManager() {
  return nodeManager_.get();
}

bool BaseAudioContext::isRunning() const {
  return state_ == ContextState::RUNNING;
}

bool BaseAudioContext::isSuspended() const {
  return state_ == ContextState::SUSPENDED;
}

bool BaseAudioContext::isClosed() const {
  return state_ == ContextState::CLOSED;
}

float BaseAudioContext::getNyquistFrequency() const {
  return sampleRate_ / 2.0f;
}

std::string BaseAudioContext::toString(ContextState state) {
  switch (state) {
    case ContextState::SUSPENDED:
      return "suspended";
    case ContextState::RUNNING:
      return "running";
    case ContextState::CLOSED:
      return "closed";
    default:
      throw std::invalid_argument("Unknown context state");
  }
}

std::shared_ptr<PeriodicWave> BaseAudioContext::getBasicWaveForm(
    OscillatorType type) {
  switch (type) {
    case OscillatorType::SINE:
      if (cachedSineWave_ == nullptr) {
        cachedSineWave_ =
            std::make_shared<PeriodicWave>(sampleRate_, type, false);
      }
      return cachedSineWave_;
    case OscillatorType::SQUARE:
      if (cachedSquareWave_ == nullptr) {
        cachedSquareWave_ =
            std::make_shared<PeriodicWave>(sampleRate_, type, false);
      }
      return cachedSquareWave_;
    case OscillatorType::SAWTOOTH:
      if (cachedSawtoothWave_ == nullptr) {
        cachedSawtoothWave_ =
            std::make_shared<PeriodicWave>(sampleRate_, type, false);
      }
      return cachedSawtoothWave_;
    case OscillatorType::TRIANGLE:
      if (cachedTriangleWave_ == nullptr) {
        cachedTriangleWave_ =
            std::make_shared<PeriodicWave>(sampleRate_, type, false);
      }
      return cachedTriangleWave_;
    case OscillatorType::CUSTOM:
      throw std::invalid_argument(
          "You can't get a custom wave form. You need to create it.");
      break;
  }
}

} // namespace audioapi
