namespace Beta3D;

public abstract class TextureView : IDisposable
{
    public Texture Texture { get; }
    public int BaseMipLevel { get; }
    public int MipLevels { get; }

    public abstract bool IsDisposed { get; }


    public TextureView(Texture texture, int baseMipLevel, int mipLevels)
    {
        Texture = texture;
        BaseMipLevel = baseMipLevel;
        MipLevels = mipLevels;
    }

    public int GetWidth(int mipLevel) => Texture.GetWidth(mipLevel);

    public int GetHeight(int mipLevel) => Texture.GetHeight(mipLevel);

    public abstract void Dispose();
}
