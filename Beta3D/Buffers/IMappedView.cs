namespace Beta3D.Buffers;

public interface IMappedView : IDisposable
{
    Span<byte> Data { get; }
}
