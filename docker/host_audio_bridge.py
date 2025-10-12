#!/usr/bin/env python3
"""
Host Audio Bridge for ROS2 JetBot Tools
This script runs on the host and bridges ROS2 TTS messages to host audio
"""
import rclpy
from rclpy.node import Node
from std_msgs.msg import String
import subprocess
import os
import signal
import sys

class HostAudioBridge(Node):
    def __init__(self):
        super().__init__('host_audio_bridge')
        
        # Subscribe to TTS topics
        self.tts_subscription = self.create_subscription(
            String,
            '/chatbot/response',
            self.tts_callback,
            10)
        
        self.get_logger().info('Host Audio Bridge started - listening for TTS messages on /chatbot/response')
        
    def tts_callback(self, msg):
        self.get_logger().info(f'TTS: {msg.data}')
        try:
            # Use espeak to convert text to speech on host
            subprocess.run(['espeak', '-s', '150', '-v', 'en', msg.data], check=True)
        except subprocess.CalledProcessError as e:
            self.get_logger().error(f'TTS error: {e}')
        except FileNotFoundError:
            self.get_logger().error('espeak not found on host - please install: sudo apt install espeak')

def signal_handler(sig, frame):
    print('\nShutting down Host Audio Bridge...')
    rclpy.shutdown()
    sys.exit(0)

def main():
    # Set up signal handler for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)
    
    # Set ROS_DOMAIN_ID to match the container
    os.environ['ROS_DOMAIN_ID'] = '7'
    
    rclpy.init()
    node = HostAudioBridge()
    
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        rclpy.shutdown()

if __name__ == '__main__':
    main()
